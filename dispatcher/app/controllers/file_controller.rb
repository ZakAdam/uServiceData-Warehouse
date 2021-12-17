class FileController < ApplicationController
  #skip_before_action :verify_authenticity_token

  def new
    if params[:file_type] == "GLS"
      render json: {response: "\n\n\n\nGLS file successfully received!\n\n\n\n"}
      return
    end
    puts "\n\nLets gooooooooooooooooooooooooooooooooooo\n\n"
    render json: {response: "\n\n\n\nsicko zbehlo jako ma\n\n\n\n"}
  end

end
