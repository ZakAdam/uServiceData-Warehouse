require 'sidekiq'
require 'rest-client'
require 'dotenv'

Dotenv.load

class TestWorker
  include Sidekiq::Job
  sidekiq_options queue: 'transport_invoices'

  def perform(name, age)
    puts Time.now
    puts "I am #{name}, running my first job at #{age}"
    puts 'Sidekiq funguje!'
  end
end
