# processor.rb
require 'sinatra'
require 'smarter_csv'
require 'roo-xls'
require 'roo'
require 'nori'
require 'rest-client'
require 'json'
require './graph_access.rb'

before do
  #content_type :json
  @docker_id = `cat /etc/hostname`
end

get '/' do
  #'Hello world!'

  query = QueryDB.new.process('.xml', 'utf-8')

  query
end

post '/semantic/process' do
  puts 'RODO'
  puts params
  puts params['file']
  puts params['file'][:tempfile].path
  # This calls will be later split on standalone containers
  # 1. get file type
  file = params['file'][:tempfile]


  puts 'AWARE'
  result = file_endings(file.path)
  puts result
  puts QueryDB.new.get_by_charset(result[2])
end

post '/apache-tika' do
  response = RestClient.post 'localhost:9998/rmeta/form/text', :upload => params['file'][:tempfile]
  file_data = JSON.parse(response)[0]

  puts file_data.class

  file_data.to_s
end

private

# Later standalone service
def file_endings(file)
  name_ending = File.extname(file)
  file_type = IO.popen(
    ['file', '--brief', '--mime-type', file],
    in: :close, err: :close
  ) { |io| io.read.chomp }

  file_charset = IO.popen(
    ['file', '--brief', '--mime', file],
    in: :close, err: :close
  ) { |io| io.read.chomp.split(';')[1].split('=')[1].strip }

  [name_ending, file_type, file_charset]
end

post '/gls_invoice/process' do
  file = Roo::Spreadsheet.open(params['file'][:tempfile], extension: :xls)
  jid = params[:jid]

  rows = file.parse(headers: true)

  RestClient.post 'saver:3000/transport_invoices/save', :file_type => params[:file_type], :file => transform, :docker_id => @docker_id, :jid => jid
end

post '/heureka_reviews/process' do
  parser = Nori.new
  parsed_reviews = parser.parse(params['reviews'])

  RestClient.post 'saver:3000/heureka_reviews/save', :reviews => parsed_reviews, :docker_id => @docker_id
end

post '/dpd_invoice/process' do
  data = SmarterCSV.process(params['file'][:tempfile].path, {col_sep: ';'})

  RestClient.post 'saver:3000/package_tracking/save', :trackings => data, :docker_id => @docker_id
end
