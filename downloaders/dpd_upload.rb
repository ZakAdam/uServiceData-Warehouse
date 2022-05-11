load '../downloaders/sftp_csv_downloader.rb'

puts Time.now

(1..1).each { |i|
  puts i
  SftpCsvDownloader.perform_async('DPD')
}
