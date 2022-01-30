require 'rest-client'

class PostsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
  end

  def create
    puts params
    puts params[:file].class

    #result = RestClient.post "localhost:4001/new_file", {'x' => 1}.to_json, {content_type: :json, accept: :json}

    #result = NewInvoiceUpload.perform_async(params[:file])
    #puts result

    uploader = FileUploader.new
    if uploader.store!(params[:file])
      puts params
      puts ';;;;;'
      puts params[:file].original_filename

      #result = RestClient.post "#{ENV.fetch("TRANSPORT_URL")}/gls_invoice/process", :file_type => params[:file_type], :file => params[:file]
      result = NewInvoiceUpload.perform_async(params[:file].original_filename)
      puts result

      redirect_to root_path, notice: 'File successfully uploaded!'
      end
  end

  def get_file
    puts params

    file_name = params[:name].tr(' ', '_')
    puts Dir['./public/files/*']
    #uploader = FileUploader.new
    #file = uploader.retrieve_from_store!(file_name)
    #puts file
    file = File.open("./public/files/#{file_name}")

    result = RestClient.post "#{ENV.fetch("TRANSPORT_URL")}/gls_invoice/process", :file_type => 'gls', :file => file
    puts result
  end
end
