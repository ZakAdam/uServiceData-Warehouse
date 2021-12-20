class InvoicesController < ApplicationController
  #skip_before_action :verify_authenticity_token

  def new
    puts "\n\nSOM v invoices controllery\n\n"
    sleep(20)
    if params[:file_type] == "GLS"
      puts params

      puts params[:file].read
    end

    render json: { response: "\n\n\n\nWe have received your invoice :)\n\n\n\n" }
    #return
  end
end
