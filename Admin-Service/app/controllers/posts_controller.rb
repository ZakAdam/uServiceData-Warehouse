require 'rest-client'
require 'dotenv'

Dotenv.load

class PostsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
  end

  def create
    uploader = FileUploader.new
    if uploader.store!(params[:file])
      NewInvoiceUpload.perform_async(params[:file].original_filename, params[:conditions])

      redirect_to root_path, notice: 'File successfully uploaded!'
    end
  end

  def get_file
    file_name = params[:name].tr(' ', '_')
    conditions = params[:conditions]
    jid = params[:jid]

    file = File.open("./public/files/#{file_name}")

    if ENV['SEMANTIC-PROCESSING'] == 'true'
      RestClient.post 'semantics:4321/semantic/process', conditions:, file: file, jid: jid
    else
      RestClient.post 'processor:4567/gls_invoice/process', conditions:, file: file, jid: jid
    end
  end
end
