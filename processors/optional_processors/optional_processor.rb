# processor.rb
require 'sinatra'
require 'rest-client'
require 'json'

before do
  content_type :json
end

get '/' do
  'Hello world!'
end

post '/geo_location/keep_country' do
  puts 'Provided data are designed to be kept in their original country.'

  # Query file_type by id, to get country?

  RestClient.post url.to_s, file_type: params[:file_type], file: data, docker_id: @docker_id, jid: jid
end

post '/heureka_reviews/process' do
  parser = Nori.new
  parsed_reviews = if params.key?(:file)
                     parser.parse(params['file'][:tempfile].read)
                   else
                     parser.parse(params['reviews'])
                   end

  RestClient.post "saver:3000/heureka_reviews/save", :reviews => parsed_reviews, :docker_id => @docker_id
end

post '/dpd_invoice/process' do
  RestClient.post "saver:3000/package_tracking/save", :trackings => data, :docker_id => @docker_id
end

post '/package_tracking/process' do
  data = SmarterCSV.process(params['file'][:tempfile].path, {col_sep: ';'})

  response = RestClient.get 'saver:3000/package_simple/last_id'
  last_id = JSON.parse(response.body)['id']
  response = RestClient.get 'saver:3000/package_simple/depots'
  @depots = JSON.parse(response.body)

  RestClient.post "saver:3000/package_simple/save", :new_trackings => new_trackings, :new_trackings_details => new_trackings_details, :new_consignee => new_consignee, :docker_id => @docker_id
end

post '/single_reviews/process' do
end
