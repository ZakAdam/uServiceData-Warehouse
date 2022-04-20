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

  def perform(review_params, product_params)
    RestClient.post "saver:3000/review/save", review_param: review_params, product_param: product_params, docker_id: '¯\_(ツ)_/¯'
  end
end
