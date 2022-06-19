load '../downloaders/sftp_csv_downloader.rb'

puts Time.now

(1..10).each { |i|
  puts i
  SftpCsvDownloader.perform_async
}
