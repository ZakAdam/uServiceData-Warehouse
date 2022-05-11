require 'sidekiq'
require 'sidekiq-cron'
require 'rest-client'
require 'dotenv'

Dotenv.load

sidekiq_config = { url: ENV['REDIS_SIDEKIQ_URL'] }

Sidekiq.configure_server do |config|
  config.redis = sidekiq_config
end

Sidekiq.configure_client do |config|
  config.redis = sidekiq_config
end


class HeurekaReviewsDownloader
  include Sidekiq::Worker
  sidekiq_options :retry => 2

  def perform
    reviews = RestClient.get 'https://www.heureka.sk/direct/dotaznik/export-product-review.php?key=6f9ae66e45fc9983e0c9c99407071f77'

    puts ENV['SINGLE']
    if ENV['SINGLE'] == 'true'
      RestClient.post "processor:4567/single_reviews/process", :reviews => reviews
    else
      RestClient.post "processor:4567/heureka_reviews/process", :reviews => reviews
    end
  end
end

#HeurekaReviewsDownloader.perform_async
#Sidekiq::Cron::Job.create(name: 'Hard worker - every hour', cron: '0 0 * * *', class: 'HeurekaReviewsDownloader')