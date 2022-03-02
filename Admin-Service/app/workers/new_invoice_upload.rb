class NewInvoiceUpload
  include Sidekiq::Worker
  sidekiq_options queue: 'transport_invoices'

  def perform(file_name)
    #puts "\n\n"
    #result = RestClient.post "#{ENV.fetch("TRANSPORT_URL")}/gls_invoice/process", :file_type => 'gls', :file => file
    #puts result
    #puts 'Toto je vypis pri prilezitsti noveho uploadu :)'
    #puts "\n\n"

    puts "\n\n"
    #response = RestClient.get "#{ENV.fetch("FILE_URL")}/get_file", {params: {name: file_name}}
    response = RestClient.get "admin_service:3000/get_file", {params: {name: file_name}}
    puts response
    puts 'Toto je vypis pri prilezitsti noveho uploadu :)'
    puts "\n\n"
  end
end
