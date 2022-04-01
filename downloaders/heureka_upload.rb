load '../downloaders/heureka_reviews_downloader.rb'

puts Time.now

(1..10).each { |i|
  puts i
  HeurekaReviewsDownloader.perform_async
}