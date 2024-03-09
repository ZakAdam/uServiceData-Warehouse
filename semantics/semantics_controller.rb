# semantics_controller.rb
require 'sinatra'
require 'rest-client'
require 'json'
require 'nokogiri'
load './graph_manager.rb'
load 'tags/tags_manager.rb'

before do
  #content_type :json
  @docker_id = `cat /etc/hostname`
end

get '/' do
  'Hello world!'
end

post '/semantic/process' do
  puts params['file'][:tempfile].path
  puts '-------------------'
  puts params
  # This calls will be later split on standalone containers
  # 1. get file type
  file = params['file'][:tempfile]
  conditions = params['conditions'].split(', ')

  result = file_endings(file.path)
  headers = get_headers(file)
  language = get_language(headers.gsub(/[,|;\t_]/, ' ')) #/[,|;\t]/

  # split headers
  delimiters = /\t|,|;|\n/
  headers = headers.split(delimiters).reject(&:empty?)

  data_hash = { file_ending: result[0], mime_type: result[1], charset: result[2], language:, headers:, conditions: }

  ########################################################################
  # Create three requests to specified semantic approaches
  responses = []
  threads = []
  endpoints = semantic_methods

  endpoints.each do |url|
    threads << Thread.new do
      response = RestClient.post url.to_s, data: data_hash.to_json
      puts response
      # responses << response.body
      responses << response
    end
  end

  threads.each(&:join) # Wait for all threads to finish
  puts "Responses: #{responses.join(', ')}"

  if ENV['ONTOLOGY'] == 'true'
    urls = JSON.parse(responses[0])
  elsif ENV['TAGGING'] == 'true'
    urls = JSON.parse(responses[0])
  else
    puts 'No semantic approach selected, ending processing!'
    return 200
  end

  puts "Selected URLs by Graph are: #{urls}"

  RestClient.post urls[0].to_s,
                  file_type: result[1],
                  file: File.open(file),
                  urls: urls,
                  url_index: 1

end

post '/graph/process' do
  data = JSON.parse(params[:data])

  supplier = create_query(data['file_ending'], data['mime_type'], data['charset'], data['language'], data['headers']).first
  supplier_name = supplier.rdfs__label.downcase

  ########## Create correct workflow
  paths = find_all_paths(supplier)
  best_path = get_path_conditions(paths, data['conditions'] << supplier_name)
  urls = get_urls(best_path)

  puts "Graph identified supplier as: #{supplier_name}"
  urls.to_s
end

post '/apache-tika' do
  headers = get_headers(params['file'][:tempfile])
  language = get_language(headers.gsub(/[,|;\t_]/, ' ')) #/[,|;\t]/

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
    header_row = doc.search('*').map(&:name).uniq.join(',')
  else
    rows = file_data['X-TIKA:content'].split("\n")
    rows.each do |line|
      if line.strip != '' && !line.strip.match(/^Client_\d+_Inv/)
        header_row = line
        break
      end
    end
  end

  header_row
end

def get_language(headers)
  # language = RestClient.put('localhost:9998/language/stream', headers:)
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

  name_ending = 'csv' if name_ending.empty? && file_type == 'text/plain'

  [name_ending, file_type, file_charset]
end

def get_by_four(file_ending, file_type, charset, language)
  puts file_ending, file_type, charset, language
  Supplier.as(:n).query
          .match('(n)-[:ns0__HAS_fileType]->(:ns0__Type {ns0__fileEnding: $file_ending, ns0__mimeType: $file_type})')
          .match('(n)-[:ns0__HAS_charSet]->(:ns0__Charset {ns0__charSet: $charset})')
          .optional_match('(n)-[:ns0__HAS_language]->(:ns0__Language {ns0__code: $language})')
          .params(file_ending:, file_type:, charset:, language:)
          .pluck(:n)
end

def create_query(file_ending, file_type, charset, language, headers)
  query = Supplier.as(:n).query

  # Define your parameters as a hash
  parameters = {}

  # REMOVED bcs headings doesnt work otherwise :) ALSO file_ending shouldn't be required options, as it can be false
  # unless file_ending.nil? || file_ending.empty?
  #   query = query.match('(n)-[:ns0__HAS_fileType]->(:ns0__Type {ns0__fileEnding: $file_ending})')
  #   parameters[:file_ending] = file_ending
  # end

  # Add a MATCH clause for file_type if it is provided
  unless file_type.nil? || file_type.empty?
    query = query.match('(n)-[:ns0__HAS_fileType]->(:ns0__Type {ns0__mimeType: $file_type})')
    parameters[:file_type] = file_type
  end

  # Add a MATCH clause for charset if it is provided
  unless charset.nil? || charset.empty?
    query = query.match('(n)-[:ns0__HAS_charSet]->(:ns0__Charset {ns0__charSet: $charset})')
    parameters[:charset] = charset
  end

  # Add an OPTIONAL MATCH clause for language if it is provided
  unless language.nil? || language.empty?
    query = query.optional_match('(n)-[:ns0__HAS_language]->(:ns0__Language {ns0__code: $language})')
    parameters[:language] = language
  end

  unless headers.nil? || headers.empty?
    max_headers = 5
    headers.each_with_index do |header, index|
      next if header.empty?

      #query = query.optional_match('(n)-[:ns0__fileElements]->(:ns0__Column {rdfs__label: $header})')
      #parameters[:header] = header
      query = query.optional_match("(n)-[:ns0__fileElements]->(:ns0__Column {rdfs__label: $header_#{index}})")
      parameters["header_#{index}".to_sym] = header
      #parameters[:header_1] = 'Číslo balíka'

      break if index > max_headers
    end
  end

  # Set the parameters for the query
  query = query.params(parameters)

  print query.to_cypher

  # Finally, pluck the result
  query.pluck(:n)
end

def semantic_methods
  endpoints = []

  endpoints << 'localhost:4321/graph/process' if ENV['ONTOLOGY'] == 'true'
  endpoints << 'tags:4444/tags/process' if ENV['TAGGING'] == 'true'

  endpoints
end
