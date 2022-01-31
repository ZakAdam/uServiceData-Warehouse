class InvoicesController < ApplicationController
  #skip_before_action :verify_authenticity_token

  def new
    puts "\n\nSOM v invoices controllery\n\n"
    if params[:file_type] == "GLS"
      result = RestClient.post "http://172.19.0.1:4003/gls_invoice", :file_type => params[:file_type], :file => params[:file]
      puts result
    end

    render json: { response: "\n\n\n\nWe have received your invoice :)\n\n\n\n" }
  end
end
