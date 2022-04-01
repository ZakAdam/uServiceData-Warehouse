require 'sidekiq'
require 'sidekiq-cron'
require 'rest-client'
require 'dotenv'

Dotenv.load

sidekiq_config = { url: ENV['REDIS_SIDEKIQ_URL'] }
#sidekiq_config[:password] = ENV['REDIS_PASSWORD'] if ENV['REDIS_PASSWORD'].present?

Sidekiq.configure_server do |config|
  config.redis = sidekiq_config
end

Sidekiq.configure_client do |config|
  config.redis = sidekiq_config
end

class StoreReview
  include Sidekiq::Worker
  sidekiq_options queue: 'heureka_single'
  sidekiq_options :retry => 0

  puts 'PLZzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz'
  def perform(review_params, product_params)
    puts "\n\n"

    puts 'HALOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO'
    #response = RestClient.get "#{ENV.fetch("FILE_URL")}/get_file", {params: {name: file_name}}
    #response = RestClient.get "admin_service:3000/get_file", {params: {name: file_name}}
    #RestClient.post "saver:3000/review/save", {params: {review: review_params, product: product_params}}

    puts review_params
    puts product_params

    RestClient.post "saver:3000/review/save", review_param: review_params, product_param: product_params, docker_id: '¯\_(ツ)_/¯'

    puts 'Skoncil som poslanie na StoreReivew'
  end
end
