class NewInvoiceUpload
  include Sidekiq::Worker
  sidekiq_options queue: 'transport_invoices'

  def perform(file)
    puts "\n\n"
    result = RestClient.post "#{ENV.fetch("TRANSPORT_URL")}/gls_invoice/process", :file_type => 'gls', :file => file
    puts result
    puts 'Toto je vypis pri prilezitsti noveho uploadu :)'
    puts "\n\n"
  end
end
