require 'rest-client'

class PostsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
  end

  def create
    puts params
    puts params[:file].class

    #result = RestClient.post "localhost:4001/new_file", {'x' => 1}.to_json, {content_type: :json, accept: :json}

    uploader = FileUploader.new
    if uploader.store!(params[:file])
      result = RestClient.post "localhost:4001/new_file", :file_type => params[:file_type], :file => params[:file]
      puts result

      redirect_to root_path, notice: 'File successfully uploaded!'
    end
  end
end
