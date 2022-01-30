require 'sidekiq'

sidekiq_config = { url: ENV['REDIS_SIDEKIQ_URL'] }
#sidekiq_config[:password] = ENV['REDIS_PASSWORD'] if ENV['REDIS_PASSWORD'].present?

Sidekiq.configure_server do |config|
  config.redis = sidekiq_config
end

Sidekiq.configure_client do |config|
  config.redis = sidekiq_config
end

