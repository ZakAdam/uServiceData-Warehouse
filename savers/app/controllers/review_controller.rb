class ReviewController < ApplicationController
  def new_review
    start_time = Time.now

    params.permit!
    product_hash = params[:product_param]

    product = Product.create(product_hash)

    params[:review_param].each do |review|
      review[:product_id] = product.id
      Review.create(review)
    end
    Log.create({log_type: "review_single", records_number: 1, started_at: start_time, ended_at: Time.now, information: params[:docker_id]})
  end


end
