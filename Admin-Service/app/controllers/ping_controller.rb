class PingController < ApplicationController
  def index
    server = Net::Ping::External.new('104.248.249.58')
    @available = server.ping?
  end
end