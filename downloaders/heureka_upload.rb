load 'heureka_reviews_downloader.rb'

puts Time.now

(1..1).each { |i|
  puts i
  HeurekaReviewsDownloader.perform_async
}
