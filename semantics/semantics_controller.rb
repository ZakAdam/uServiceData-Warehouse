# processor.rb
require 'sinatra'
require 'smarter_csv'
require 'roo-xls'
require 'roo'
require 'nori'
require 'rest-client'
require 'json'
require 'nokogiri'
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
  puts params['file'][:tempfile].path
  # This calls will be later split on standalone containers
  # 1. get file type
  file = params['file'][:tempfile]


  puts 'AWARE'
  result = file_endings(file.path)
  headers = get_headers(file)
  language = get_language(headers.gsub(/[,|;\t_]/, ' '))    #/[,|;\t]/
  #puts QueryDB.new.get_by_charset(result[2])

  lel = QueryDB.new.get_by_four(result[0], result[1], result[2], language)
  puts lel
  #lel.to_s

  url = lel.first.endpoint.ns0__url
  RestClient.post "processor:4567#{url}", file_type: result[1], file: file, jid: 0
end

post '/apache-tika' do
  headers = get_headers(params['file'][:tempfile])
  language = get_language(headers.gsub(/[,|;\t_]/, ' '))    #/[,|;\t]/

  puts language, headers
  headers
end

private

def get_headers(file)
  # testing file
  # file = File.open('../files/test_files/Heureka/product-review-muziker-sk.xml')
  response = RestClient.post 'localhost:9998/rmeta/form/text', upload: file
  file_data = JSON.parse(response)[0]
  header_row = nil

  if ['application/xml'].include?(file_data['Content-Type'])
    # parse specific file types, such as XML
    doc = File.open(file) { |f| Nokogiri::XML(f) }
    header_row = doc.search('*').map(&:name).uniq.join(' ')
  else
    rows = file_data['X-TIKA:content'].split("\n")
    rows.each do |line|
      if line.strip != '' && !line.strip.match(/^Client_\d+_Inv/)
        header_row = line
        break
      end
    end

    puts header_row
    header_row
  end
end

def get_language(headers)
  language = RestClient.put('localhost:9998/language/stream', headers:)

  puts "Language for the file is: #{language}"
  language
end

# Later standalone service
def file_endings(file)
  name_ending = File.extname(file).delete_prefix('.')
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

  RestClient.post 'saver:3000/transport_invoices/save', file_type: params[:file_type], file: transform, docker_id: @docker_id, jid:
end

post '/heureka_reviews/process' do
  parser = Nori.new
  parsed_reviews = parser.parse(params['reviews'])

  RestClient.post 'saver:3000/heureka_reviews/save', reviews: parsed_reviews, docker_id: @docker_id
end

post '/dpd_invoice/process' do
  data = SmarterCSV.process(params['file'][:tempfile].path, {col_sep: ';'})

  RestClient.post 'saver:3000/package_tracking/save', trackings: data, docker_id: @docker_id
end
