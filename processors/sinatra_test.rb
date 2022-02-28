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
  @docker_id = `cat /etc/hostname`
end

get '/' do
  'Hello world!'
end

post '/gls_invoice/process' do
  puts 'lol'
  puts params
  file = Roo::Spreadsheet.open(params['file'][:tempfile], extension: :xls)

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
  result = RestClient.post "saver:3000/transport_invoices/save", :file_type => params[:file_type], :file => transform, :docker_id => @docker_id
  puts result
end

post '/heureka_reviews/process' do
  parser = Nori.new
  parsed_reviews = parser.parse(params['reviews'])
  #result = RestClient.post "#{ENV.fetch("HEUREKA_URL")}/heureka_reviews/save", :reviews => parsed_reviews
  result = RestClient.post "saver:3000/heureka_reviews/save", :reviews => parsed_reviews, :docker_id => @docker_id
  puts result
end

private
def get_customer_name(row)
  name = row.split('     ')
  name[0]
end

post '/dpd_invoice/process' do
  data = SmarterCSV.process(params['file'][:tempfile].path, {col_sep: ';'})
  #docker_id = `cat /etc/hostname`
  #result = RestClient.post "#{ENV.fetch("TRACKING_URL")}/package_tracking/save", :trackings => data
  result = RestClient.post "saver:3000/package_tracking/save", :trackings => data, :docker_id => @docker_id
  puts result
end
