class StaticsController < ApplicationController
  def home
    #json = RestClient.get 'localhost:3000/firstname'
    #@data = JSON.parse(json)
    @logs = Log.all
  end
end
