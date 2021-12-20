#require 'eventmachine'
#require 'em-http'

class FileController < ApplicationController
  #skip_before_action :verify_authenticity_token

  def new
    if params[:file_type] == "GLS"
      Thread.new do
        result = RestClient.post "http://172.19.0.1:4002/new_invoice/", :file_type => params[:file_type], :file => params[:file]
        puts result
      end
      #result = RestClient.post "localhost:4001/new_file", :file_type => params[:file_type], :file => params[:file]
      #puts result


      #EventMachine.run {
      #  http = EventMachine::HttpRequest.new('http://localhost:4002/new_invoice/').post :query => {'keyname' => 'value'}

      #  http.errback {
      #    p http.errback
      #    p http.response_header.status
      #    p http.response_header
      #    p http.response
      #    p 'Uh oh'
      #    EM.stop }
      #  http.callback {
      #    p http.response_header.status
      #    p http.response_header
      #    p http.response

      #    EventMachine.stop
      #  }
      #}

      render json: { response: "\n\n\n\nGLS file successfully received!\n\n\n\n" }
      return
    end
    puts "\n\nLets gooooooooooooooooooooooooooooooooooo\n\n"
    render json: { response: "\n\n\n\nsicko zbehlo jako ma\n\n\n\n" }
  end

end
