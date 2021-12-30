class HeurekaReviewsController < ApplicationController
  def new_review
    @new_reviews = []
    parsed_reviews = params[:reviews]

    parsed_reviews['products']['product'].each do |product|
      puts product['product_name']
    end
  end

  private
  def parse_review(product)
    product[]
  end
end
