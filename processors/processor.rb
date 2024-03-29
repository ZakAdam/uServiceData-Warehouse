# processor.rb
require 'sinatra'
require 'smarter_csv'
require 'roo-xls'
require 'roo'
require 'nori'
require 'rest-client'
require 'json'
require_relative 'lib/reviews_sidekiq'

before do
  content_type :json
  @docker_id = `cat /etc/hostname`
end

get '/' do
  'Hello world!'
end

post '/gls_invoice/process' do
  file = Roo::Spreadsheet.open(params['file'][:tempfile], extension: :xls)
  jid = params[:jid]

  rows = file.parse(headers: true)
  transform = rows.map do |row|
    {
      package_number: row['Číslo balíka'],
      invoice_number: row['InvoiceNo'],
      carrier: 'gls',
      invoice_date: row['InvoiceDate'],
      delivery_date: row['DeliverDate'],
      delivery_cash: row['Dobierka'],
      fees: row['TollFee'] +
            row['Diesel Fee'] +
            row['TransportFee'] +
            row['SVFee'] +
            row['CodFee'] +
            row['OverWeightFee'] +
            row['ExpressFee'] +
            row['CreditCardFee'] +
            row['ManualLabelFee'],
      price: row['Cena'],
      country: row['Štát'],
      customer: get_customer_name(row['PostalAddr'].to_s),
      city: row['Mesto'],
      zipcode: row['PSČ'],
      address: row['PostalAddr']
    }
  end

  RestClient.post "saver:3000/transport_invoices/save", file_type: params[:file_type], file: transform, docker_id: @docker_id, jid:
end

post '/heureka_reviews/process' do
  parser = Nori.new
  parsed_reviews = if params.key?(:file)
                     parser.parse(params['file'][:tempfile].read)
                   else
                     parser.parse(params['reviews'])
                   end

  RestClient.post "saver:3000/heureka_reviews/save", reviews: parsed_reviews, docker_id: @docker_id
end

post '/dpd_invoice/process' do
  data = SmarterCSV.process(params['file'][:tempfile].path, { col_sep: ';' })

  RestClient.post "saver:3000/package_tracking/save", trackings: data, docker_id: @docker_id
end

post '/csv/process' do
  data = SmarterCSV.process(params['file'][:tempfile].path, { col_sep: ',' })

  RestClient.post "saver:3000/store_rows/save", data:, docker_id: @docker_id
end

post '/package_tracking/process' do
  data = SmarterCSV.process(params['file'][:tempfile].path, {col_sep: ';'})

  response = RestClient.get 'saver:3000/package_simple/last_id'
  last_id = JSON.parse(response.body)['id']
  response = RestClient.get 'saver:3000/package_simple/depots'
  @depots = JSON.parse(response.body)


  new_trackings = []
  new_trackings_details = []
  new_consignee = []

  data.each do |tracking|
    new_trackings = parse_tracking(tracking, last_id, new_trackings)
    new_trackings_details = parse_trackings_detail(tracking, new_trackings_details)
    new_consignee = parse_consignee(tracking, new_consignee)
    last_id = last_id + 1
  end

  RestClient.post "saver:3000/package_simple/save", new_trackings:, new_trackings_details:, new_consignee:, docker_id: @docker_id
end

post '/single_reviews/process' do
  parser = Nori.new
  parsed_reviews = parser.parse(params['reviews'])

  parsed_reviews['products']['product'].each do |product|
    review_params = parse_review(product)
    product_params = parse_product(product)


    StoreReview.perform_async(review_params, product_params)
  end
end

private
def get_customer_name(row)
  name = row.split('     ')
  name[0]
end

def parse_review(product)
  review_params = []
  product['reviews'].each do |review|
    review = review[1]
    converted_time = Time.at(review['unix_timestamp'].to_i)
    review_hash = {
      rating: review['rating'],
      summary: nil,
      converted_timestamp: converted_time,
      original_id: review['rating_id'],
      unix_timestamp: review['unix_timestamp'],
      product_id: nil
    }

    if review.key?('pros')
      review_hash[:pros] = review['pros']
    end
    if review.key?('summary')
      review_hash[:summary] = review['summary']
    end
    if review.key?('cons')
      review_hash[:cons] = review['cons']
    end
    review_params.append(review_hash)

  end
  review_params
end

def parse_product(product)
  {name: product['product_name'],
                 url: product['url'],
                 price: product['price'],
                 rating: product['reviews']['review']['rating'],
                 ean: product['ean'],
                 product_number: product['productno'],
                 order_id: product['order_id']}
end

# for DPD invoices
def parse_depot(code, name)
  depot_id = @depots["#{code}"]
  if depot_id.nil?
    @depots = RestClient.post('saver:3000/package_simple/new_depot', code:, name:)
    depot_id = @depots["#{code}"]
  end
  depot_id
end

def parse_consignee(tracking, new_consignee)
  new_consignee.append({name: tracking[:receiver_name], zipcode: tracking[:consignee_zip], country_code: tracking[:consignee_country_code]})
  new_consignee
end

def parse_tracking(tracking, last_id, new_trackings)
  new_trackings.append({parcel_no: tracking[:parcelno],
                         scan_code: tracking[:scan_code],
                         date: DateTime.parse(tracking[:event_date_time].to_s),
                         customer_reference: tracking[:customer_reference],
                         depot_id: parse_depot(tracking[:depot_code], tracking[:depotname]),
                         consignee_id: last_id,
                         tracking_detail_id: last_id})
  new_trackings
end

def parse_trackings_detail(tracking, new_trackings_details)
  new_trackings_details.append({service: tracking[:service],
                                 add_service_1: tracking[:add_service_1],
                                 add_service_2: tracking[:add_service_2],
                                 add_service_3: tracking[:add_service_3],
                                 info_text: tracking[:info_text],
                                 weight: tracking[:weight] })
  new_trackings_details
end
