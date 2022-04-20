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

class OldNewInvoiceUpload
  include Sidekiq::Worker
  sidekiq_options queue: 'transport_invoices'
  sidekiq_options :retry => 0

  def perform(file_name)
    RestClient.get "admin_service:3000/get_file", {params: {name: file_name}}
  end
end
