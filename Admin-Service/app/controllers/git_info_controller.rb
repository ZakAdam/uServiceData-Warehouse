class GitInfoController < ApplicationController
  def index
    json = RestClient.get 'https://api.github.com/repos/ZakAdam/Admin-Service/commits'
    render json: JSON.parse(json)[0].to_json
  end
end
