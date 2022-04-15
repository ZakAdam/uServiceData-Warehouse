require 'dotenv'
require 'sidekiq'
require 'net/sftp'
require 'tempfile'
require 'rest-client'

Dotenv.load

sidekiq_config = { url: ENV['REDIS_SIDEKIQ_URL'] }
#sidekiq_config[:password] = ENV['REDIS_PASSWORD'] if ENV['REDIS_PASSWORD'].present?

Sidekiq.configure_server do |config|
  config.redis = sidekiq_config
end

Sidekiq.configure_client do |config|
  config.redis = sidekiq_config
end

class SftpCsvDownloader
  include Sidekiq::Worker
  sidekiq_options queue: 'sftp_queue'

  def perform(folder)
    options = {host: ENV['SFTP_HOST'],
               user: ENV['SFTP_USER'],
               password: ENV['SFTP_PASSWORD']}

    @session = Net::SSH.start(options[:host], options[:user], { password: options[:password] })
    @sftp = Net::SFTP::Session.new(@session)

    @sftp.connect!

    files = recursive_files(folder)
    download_files(files)
    process_files(files)
  end

  # Returns list of files inside all subfolders
  def recursive_files(folder)
    files = []

    @sftp.dir.entries(folder).each do |item|
      next if %w[. ..].include?(item.name)

      if item.file?
        files << "#{folder}/#{item.name}"
      else
        files_in_subfolder = recursive_files("#{folder}/#{item.name}")

        files.concat files_in_subfolder
      end
    end

    files
  end


  def download_files(files)
    files.each do |filename|
      file = File.open("./#{filename}", 'w')
      @sftp.download! filename, file.path
      file.close
    end
  end

  def process_files(files)
    files.each do |filename|
      file = File.new("./#{filename}")

      result = RestClient.post "processor:4567/dpd_invoice/process", :file => file, :content_type => 'application/octet-stream'
      #result = RestClient.post "processor:4567/package_tracking/process", :file => file, :content_type => 'application/octet-stream'

      file.close
      puts result
    end
  end
end

#SftpCsvDownloader.perform_async('DPD')