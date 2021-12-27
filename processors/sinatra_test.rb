# sinatra_test.rb
require 'sinatra'
require 'smarter_csv'
require 'roo-xls'
require 'roo'
require 'rest-client'

before do
  content_type :json
end

get '/' do
  'Hello world!'
end

post '/gls_invoice/process' do
  'this is gls invoice process for their processing ;)'

  file = Roo::Spreadsheet.open(params['file'][:tempfile], extension: :xls)

  rows = file.parse(headers: true)
  transform = rows.map do |row|
    {
      package_number: row['Číslo balíka'],
      invoice_number: row['InvoiceNo'],
      carrier: 'gls',
      invoice_date: row['InvoiceDate'],
      delivery_date: row['DeliverDate'],
      fees: row['TollFee'] + row['Diesel Fee'] + row['TransportFee'] + row['SVFee'] + row['CodFee'] + row['OverWeightFee'] + row['ExpressFee'] + row['CreditCardFee'] + row['ManualLabelFee'],
      country: row['Štát'],
      customer: get_customer_name(row['PostalAddr'].to_s),
      city: row['Mesto'],
      zipcode: row['PSČ'],
      address: row['PostalAddr']

    }
  end

  puts transform[1]
  #content_type :json
  { first_zaznam: transform[1] }.to_json

  result = RestClient.post "localhost:4000/transport_invoices/save", :file_type => params[:file_type], :file => transform
  puts result
  #render json: { first_zaznam: transform[1] }
  #puts transform

end

private
def get_customer_name(row)
  name = row.split('     ')
  #puts name[0]
  name[0]
end

post '/dpd_invoice/process' do
  data = SmarterCSV.process(params['file'][:tempfile], {col_sep: ';'})   # potrebujes file
  {data: data}.to_json
end
