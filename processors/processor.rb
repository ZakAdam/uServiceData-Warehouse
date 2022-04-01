# processor.rb
require 'sinatra'
require 'smarter_csv'
require 'roo-xls'
require 'roo'
require 'nori'
require 'rest-client'
require 'dotenv'
require_relative 'lib/reviews_sidekiq'

Dotenv.load

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
      fees: row['TollFee'] + row['Diesel Fee'] + row['TransportFee'] + row['SVFee'] + row['CodFee'] + row['OverWeightFee'] + row['ExpressFee'] + row['CreditCardFee'] + row['ManualLabelFee'],
      price: row['Cena'],
      country: row['Štát'],
      customer: get_customer_name(row['PostalAddr'].to_s),
      city: row['Mesto'],
      zipcode: row['PSČ'],
      address: row['PostalAddr']
    }
  end

  #result = RestClient.post "#{ENV.fetch("TRANSPORT_URL")}/transport_invoices/save", :file_type => params[:file_type], :file => transform
  RestClient.post "saver:3000/transport_invoices/save", :file_type => params[:file_type], :file => transform, :docker_id => @docker_id, :jid => jid
  #puts result
end

post '/heureka_reviews/process' do
  parser = Nori.new
  parsed_reviews = parser.parse(params['reviews'])
  #result = RestClient.post "#{ENV.fetch("HEUREKA_URL")}/heureka_reviews/save", :reviews => parsed_reviews
  result = RestClient.post "saver:3000/heureka_reviews/save", :reviews => parsed_reviews, :docker_id => @docker_id
  puts result
end

post '/dpd_invoice/process' do
  data = SmarterCSV.process(params['file'][:tempfile].path, {col_sep: ';'})
  #docker_id = `cat /etc/hostname`
  #result = RestClient.post "#{ENV.fetch("TRACKING_URL")}/package_tracking/save", :trackings => data
  result = RestClient.post "saver:3000/package_tracking/save", :trackings => data, :docker_id => @docker_id
  puts result
end

post '/single_reviews/process' do
  parser = Nori.new
  parsed_reviews = parser.parse(params['reviews'])
  #result = RestClient.post "#{ENV.fetch("HEUREKA_URL")}/heureka_reviews/save", :reviews => parsed_reviews

  parsed_reviews['products']['product'].each do |product|
    review_params = parse_review(product)
    product_params = parse_product(product)


    StoreReview.perform_async(review_params, product_params)
  end
  puts 'LOOOOOOOOOOOl'
end

private
def get_customer_name(row)
  name = row.split('     ')
  name[0]
end

def parse_review(product)
  review_params = []
  product['reviews'].each do |review|
    review = review[1]      # odskusaj na viacej recenziach!!!
    converted_time = Time.at(review['unix_timestamp'].to_i)
    if review.key?('summary')
      review_params.append({rating: review['rating'],
                           summary: review['summary'],
                           converted_timestamp: converted_time,
                           original_id: review['rating_id'],
                           unix_timestamp: review['unix_timestamp'],
                           product_id: nil})
    else
      review_params.append({rating: review['rating'],
                           summary: nil,
                           converted_timestamp: converted_time,
                           original_id: review['rating_id'],
                           unix_timestamp: review['unix_timestamp'],
                           product_id: nil})
    end
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
