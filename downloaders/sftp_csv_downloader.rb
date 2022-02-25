require 'dotenv'
require 'sidekiq'
require 'net/sftp'

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

  def perform(folder)
    options = {host: ENV['SFTP_HOST'],
                user: ENV['SFTP_USER'],
                password: ENV['SFTP_PASSWORD']}

    #sftp_options = {}
    #sftp_options[:password] = @options[:password] if options[:password].present?
    puts 'More'
    puts options[:host]
    @session = Net::SSH.start(options[:host], options[:user], { password: options[:password] })
    puts 'SESSION'
    @sftp = Net::SFTP::Session.new(@session)

    @sftp.connect!

    files = recursive_files(folder)
    puts files
    #read_file(files)
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

  # Must return IO rewinded to the beginning
  def read_file(remote_path)
    Tempfile.new(['DownloadedFile-', File.extname(remote_path)]).tap do |tempfile|
      reconnect if @sftp.try(:closed?)

      @sftp.download! remote_path, tempfile.path

      tempfile.rewind
    end
  end
end

SftpCsvDownloader.perform_async('DPD')