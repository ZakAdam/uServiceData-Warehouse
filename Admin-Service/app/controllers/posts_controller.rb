require 'rest-client'

class PostsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
  end

  def create
    uploader = FileUploader.new
    if uploader.store!(params[:file])
      NewInvoiceUpload.perform_async(params[:file].original_filename)

      redirect_to root_path, notice: 'File successfully uploaded!'
    end
  end

  def get_file
    file_name = params[:name].tr(' ', '_')
    file_type = params[:file_type]
    jid = params[:jid]

    file = File.open("./public/files/#{file_name}")
    #RestClient.post '172.17.0.1:4321/semantic/process', file_type: file_type, file: file, jid: jid
    RestClient.post '172.17.0.1:4321/apache-tika', file_type: file_type, file: file, jid: jid
    #RestClient.post 'processor:4567/gls_invoice/process', file_type: file_type, file: file, jid: jid
  end
end
