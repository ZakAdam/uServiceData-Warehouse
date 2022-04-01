require 'rest-client'

class PostsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
  end

  def create
    #result = RestClient.post "localhost:4001/new_file", {'x' => 1}.to_json, {content_type: :json, accept: :json}

    #result = NewInvoiceUpload.perform_async(params[:file])

    uploader = FileUploader.new
    if uploader.store!(params[:file])
      #result = RestClient.post "#{ENV.fetch("TRANSPORT_URL")}/gls_invoice/process", :file_type => params[:file_type], :file => params[:file]
      NewInvoiceUpload.perform_async(params[:file].original_filename)

      redirect_to root_path, notice: 'File successfully uploaded!'
      end
  end

  def get_file
    file_name = params[:name].tr(' ', '_')
    jid = params[:jid]
    #uploader = FileUploader.new
    #file = uploader.retrieve_from_store!(file_name)
    #puts file
    file = File.open("./public/files/#{file_name}")

    puts "FILE NAME:\n"
    puts file_name
    puts "\n\n"

    File.open('Requests.txt', 'a') { |fileN| fileN.write(file_name + "\n") }
    #result = RestClient.post "#{ENV.fetch("TRANSPORT_URL")}/gls_invoice/process", :file_type => 'gls', :file => file
    RestClient.post "processor:4567/gls_invoice/process", :file_type => 'gls', :file => file, :jid => jid
  end
end
