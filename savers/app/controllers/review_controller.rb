class ReviewController < ApplicationController
  def new
    puts 'JUHUUUUUUUUUUUUUUU'
    puts "\n\n"
    puts 'JEEEEEEEEEEEEEEEEJ'
  end

  def new_review
    start_time = Time.now

    puts 'Revu????'
    puts params[:review_param]
    puts params[:product_param]
    params.permit!
    product_hash = params[:product_param]
    puts product_hash
    product = Product.create(product_hash)
    puts 'ULozene'
    params[:review_param].each do |review|
      review[:product_id] = product.id
      Review.create(review)
    end
    #review = Review.create(params[:review_param][:review])
    #product[:review_id] = review.id
    #Product.create(product)

    puts 'VYPIS'
    puts system('cat /etc/hostname')
    puts 'KONEC VYPISU'
    Log.create({log_type: "review_single", records_number: 1, started_at: start_time, ended_at: Time.now, information: params[:docker_id]})
  end


end
