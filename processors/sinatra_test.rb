# sinatra_test.rb
require 'sinatra'
require 'smarter_csv'
require 'roo-xls'
require 'roo'
require 'nori'
require 'rest-client'
require 'dotenv'

Dotenv.load

before do
  content_type :json
end

get '/' do
  'Hello world!'
end

post '/gls_invoice/process' do
  'this is gls invoice process for their processing ;)'

  puts 'lol'
  puts params
  file = Roo::Spreadsheet.open(params['file'][:tempfile], extension: :xls)

  #file_new = File.read(params[:file], encoding: 'ASCII-8BIT')
  #file_new = File.read(params[:file])

  #file = Roo::Spreadsheet.open(file_new, extension: :xls)

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

  #puts transform[1]
  #content_type :json
  #{ first_zaznam: transform[1] }.to_json

  #result = RestClient.post "localhost:4000/transport_invoices/save", :file_type => params[:file_type], :file => transform
  result = RestClient.post "#{ENV.fetch("TRANSPORT_URL")}/transport_invoices/save", :file_type => params[:file_type], :file => transform
  puts result

  transform[1].to_json
  #render json: { first_zaznam: transform[1] }
  #puts transform

end

post '/heureka_reviews/process' do
  #parsed_reviews = Nokogiri::XML.parse(params['reviews'])
  #puts params
  #file = File.open(params['reviews'][:tempfile])

  parser = Nori.new
  parsed_reviews = parser.parse(params['reviews'])
  #parsed_reviews = parser.parse(file.read)

  result = RestClient.post "#{ENV.fetch("HEUREKA_URL")}/heureka_reviews/save", :reviews => parsed_reviews

  puts result
end

private
def get_customer_name(row)
  name = row.split('     ')
  name[0]
end

post '/dpd_invoice/process' do
  data = SmarterCSV.process(params['file'][:tempfile], {col_sep: ';'})   # potrebujes file

  result = RestClient.post "#{ENV.fetch("TRACKING_URL")}/package_tracking/save", :trackings => data
  puts result
  {data: data}.to_json
end
