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

class NewInvoiceUpload
  include Sidekiq::Worker
  sidekiq_options queue: 'transport_invoices'

  def perform(file_name)
    puts "\n\n"
    #response = RestClient.get "#{ENV.fetch("FILE_URL")}/get_file", {params: {name: file_name}}
    response = RestClient.get "admin_service:3000/get_file", {params: {name: file_name}}
    puts response
    puts 'Toto je vypis pri prilezitsti noveho uploadu :)'
    puts "\n\n"
  end
end
