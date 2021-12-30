require 'sidekiq'
require 'sidekiq-cron'
require 'rest-client'

class HeurekaReviewsDownloader
  include Sidekiq::Worker

  def perform
    puts "\nLet sgoooooooooooooooooo, performujem, jako si vedel? :)\n"
    reviews = RestClient.get 'https://www.heureka.sk/direct/dotaznik/export-product-review.php?key=6f9ae66e45fc9983e0c9c99407071f77'
    result = RestClient.post "localhost:4567/heureka_reviews/process", :reviews => reviews
  end

  def start_cron
    Sidekiq::Cron::Job.create(name: 'Hard worker - every 5min', cron: '*/1 * * * *', class: 'HeurekaReviewsDownloader')
  end
end