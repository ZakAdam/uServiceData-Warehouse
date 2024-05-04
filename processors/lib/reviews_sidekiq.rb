require 'sidekiq'
require 'sidekiq-cron'
require 'rest-client'
require 'dotenv'

Dotenv.load

sidekiq_config = { host: ENV['REDIS_HOST'], port: ENV['REDIS_PORT'] }

Sidekiq.configure_server do |config|
  config.redis = sidekiq_config
end

Sidekiq.configure_client do |config|
  config.redis = sidekiq_config
end

Sidekiq.strict_args!(false)

class StoreReview
  include Sidekiq::Worker
  sidekiq_options queue: 'heureka_single'
  sidekiq_options :retry => 2

  def perform(review_params, product_params)
    docker_id = `cat /etc/hostname`
    RestClient.post "saver:3000/review/save", review_param: review_params, product_param: product_params, docker_id: docker_id
  end
end
