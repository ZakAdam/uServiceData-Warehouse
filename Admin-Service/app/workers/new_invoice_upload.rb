require 'sidekiq'
require 'rest-client'
require 'dotenv'

Dotenv.load

sidekiq_config = { host: ENV['REDIS_HOST'], port: ENV['REDIS_PORT'] }

Sidekiq.configure_server do |config|
  config.redis = sidekiq_config
end

Sidekiq.configure_client do |config|
  config.redis = sidekiq_config
end

class NewInvoiceUpload
  include Sidekiq::Job
  sidekiq_options queue: 'transport_invoices'
  sidekiq_options retry: 2

  def perform(file_name, conditions)
      RestClient::Request.execute(method: :get, url: 'admin_service:3000/get_file',
                                  timeout: 600, headers: { params: { name: file_name, conditions:, jid: } })
    rescue RestClient::Exceptions::ReadTimeout
      puts "\n\nDoslo k timeoutu!\n\n"
      puts jid
      nil
  end
end
