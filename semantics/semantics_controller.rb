# semantics_controller.rb
require 'sinatra'
require 'rest-client'
require 'json'
require 'active_graph'
require 'neo4j-ruby-driver'
Dir['./models/*.rb'].each { |file| require file }

#require './graph_access.rb'

# ActiveGraph::Base.driver = Neo4j::Driver::GraphDatabase.driver('bolt://localhost:7687', Neo4j::Driver::AuthTokens.basic('neo4j','postgres'))
ActiveGraph::Base.driver = Neo4j::Driver::GraphDatabase.driver('bolt://neo4j:7687', Neo4j::Driver::AuthTokens.basic('neo4j','postgres'))

before do
  #content_type :json
  @docker_id = `cat /etc/hostname`
end

get '/' do
  'Hello world!'
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

  # supplier = get_by_four(result[0], result[1], result[2], language)
  supplier = create_query(result[0], result[1], result[2], language)

  url = supplier.first.endpoint.ns0__url
  RestClient.post "processor:4567#{url}", file_type: result[1], file: File.open(file), jid: 0
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
  response = RestClient.post 'apach-tika:9998/rmeta/form/text', upload: file
  # response = RestClient.post 'localhost:9998/rmeta/form/text', upload: file
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
  end

  #puts header_row
  header_row
end

def get_language(headers)
  language = RestClient.put('apach-tika:9998/language/stream', headers:)

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

def get_by_four(file_ending, file_type, charset, language)
  puts file_ending, file_type, charset, language
  Supplier.as(:n).query
          .match('(n)-[:ns0__HAS_fileType]->(:ns0__Type {ns0__fileEnding: $file_ending, ns0__mimeType: $file_type})')
          .match('(n)-[:ns0__HAS_charSet]->(:ns0__Charset {ns0__charSet: $charset})')
          .optional_match('(n)-[:ns0__HAS_language]->(:ns0__Language {ns0__code: $language})')
          .params(file_ending: file_ending, file_type: file_type, charset: charset, language: language)
          .pluck(:n)
end

def create_query(file_ending, file_type, charset, language)
  puts "Testing for nil: #{file_ending.nil?}"
  puts "Testing for empty: #{file_ending.empty?}"
  puts file_ending, file_type, charset, language
  query = Supplier.as(:n).query

  # Define your parameters as a hash
  parameters = {}

  # Add a MATCH clause for file_ending if it is provided
  unless file_ending.nil? || file_ending.empty?
    query = query.match('(n)-[:ns0__HAS_fileType]->(:ns0__Type {ns0__fileEnding: $file_ending})')
    parameters[:file_ending] = file_ending
  end

  # Add a MATCH clause for file_type if it is provided
  if file_type.nil? || file_type.empty?
    query = query.match('(n)-[:ns0__HAS_fileType]->(:ns0__Type {ns0__mimeType: $file_type})')
    parameters[:file_type] = file_type
  end

  # Add a MATCH clause for charset if it is provided
  if charset.nil? || charset.empty?
    query = query.match('(n)-[:ns0__HAS_charSet]->(:ns0__Charset {ns0__charSet: $charset})')
    parameters[:charset] = charset
  end

  # Add an OPTIONAL MATCH clause for language if it is provided
  if language.nil? || language.empty?
    query = query.optional_match('(n)-[:ns0__HAS_language]->(:ns0__Language {ns0__code: $language})')
    parameters[:language] = language
  end

  # Set the parameters for the query
  query = query.params(parameters)

  print query.to_cypher

  # Finally, pluck the result
  query.pluck(:n)
end
