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

class SemanticProcessing
  include Sidekiq::Worker
  sidekiq_options queue: 'semantic_pipeline'
  sidekiq_options :retry => 2

  def perform(options, data)
    puts 'In sidekiq'
    puts options
    puts data

    #RestClient::Request.execute(method: :post, url: 'saver:3000/review/save',
    #                            timeout: 600, headers: {params: {review_param: review_params, product_param: product_params, docker_id: self.jid}})

    #RestClient.post "saver:3000/review/save", review_param: review_params, product_param: product_params, docker_id: self.jid
  end
end
