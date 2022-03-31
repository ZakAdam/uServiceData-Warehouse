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


class HeurekaReviewsDownloader
  include Sidekiq::Worker
  sidekiq_options :retry => 0

  def perform
    reviews = RestClient.get 'c'
    #result = RestClient.post "#{ENV['PROCESSOR_HOST']}/heureka_reviews/process", :reviews => reviews

    #RestClient.post "processor:4567/heureka_reviews/process", :reviews => reviews
    RestClient.post "processor:4567/single_reviews/process", :reviews => reviews
  end
end

#HeurekaReviewsDownloader.perform_async
#Sidekiq::Cron::Job.create(name: 'Hard worker - every hour', cron: '0 0 * * *', class: 'HeurekaReviewsDownloader')
#Sidekiq::Cron::Job.create(name: 'Hard worker - every hour', cron: '*/5 * * * *', class: 'HeurekaReviewsDownloader')