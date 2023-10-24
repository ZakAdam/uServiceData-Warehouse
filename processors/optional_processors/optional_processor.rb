# processor.rb
require 'sinatra'
require 'rest-client'
require 'json'

before do
  #content_type :json
end

get '/' do
  'Hello world!'
end

post '/geo_location/keep_country' do
  puts 'Provided data are designed to be kept in their original country.'

  # Query node to get next nodes:


  RestClient.post url.to_s, file_type: params[:file_type], file: data, docker_id: @docker_id, jid: jid
end

post '/notifications/send_email' do
  puts 'Sending email notification to the assigned people...'

  # Query file_type by id, to get country?

  RestClient.post url.to_s, file_type: params[:file_type], file: data, docker_id: @docker_id, jid: jid
end
