class FoodsController < ApplicationController
  def index
    json = RestClient.get 'localhost:3000/food_names'
    @data = JSON.parse(json)

    json = RestClient.get 'localhost:3000/food_prices'
    @price = JSON.parse(json).sort
  end
end
