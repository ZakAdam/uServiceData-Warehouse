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
  puts params
  puts params[:url_index]
  puts params[:urls][params[:url_index].to_i]

  # Query node to get next nodes:


  RestClient.post params[:urls][params[:url_index].to_i],
                  file_type: params[:file_type],
                  file: params[:file],
                  docker_id: @docker_id,
                  urls: params[:urls],
                  url_index: params[:url_index].to_i + 1
end

post '/notifications/send_email' do
  puts 'Sending email notification to the assigned people...'

  # Query file_type by id, to get country?

  RestClient.post params[:urls][params[:url_index].to_i],
                  file_type: params[:file_type],
                  file: params[:file],
                  docker_id: @docker_id,
                  urls: params[:urls],
                  url_index: params[:url_index].to_i + 1
end

post '/cron/schedule' do
  puts 'Creating CORN job...'
  puts 'Scheduling job...'

  # Query file_type by id, to get country?

  RestClient.post params[:urls][params[:url_index].to_i],
                  file_type: params[:file_type],
                  file: params[:file],
                  docker_id: @docker_id,
                  urls: params[:urls],
                  url_index: params[:url_index].to_i + 1
end
