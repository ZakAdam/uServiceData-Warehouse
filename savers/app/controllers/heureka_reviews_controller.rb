class HeurekaReviewsController < ApplicationController
  def new_review
    start_time = Time.now
    @new_reviews = []
    @new_products = []

    last_product_id = 1
    if Product.exists?
      last_product_id = Product.last.id + 1
    end
    parsed_reviews = params[:reviews]

    number_of_records = 0

    parsed_reviews['products']['product'].each do |product|
      parse_review(product, last_product_id)
      parse_product(product)
      last_product_id += 1
      number_of_records = number_of_records + 1
    end
    Product.insert_all(@new_products)
    Review.insert_all(@new_reviews)
    
    Log.create({log_type: "review", records_number: number_of_records, started_at: start_time, ended_at: Time.now, information: params[:docker_id]})
  end

  private
  def parse_review(product, product_id)
    product['reviews'].each do |review|
      review = review[1]
      converted_time = Time.at(review['unix_timestamp'].to_i)
      if review.key?('summary')
        @new_reviews.append({rating: review['rating'],
                             summary: review['summary'],
                             converted_timestamp: converted_time,
                             original_id: review['rating_id'],
                             unix_timestamp: review['unix_timestamp'],
                             product_id: product_id})
      else
        @new_reviews.append({rating: review['rating'],
                             summary: nil,
                             converted_timestamp: converted_time,
                             original_id: review['rating_id'],
                             unix_timestamp: review['unix_timestamp'],
                             product_id: product_id})
      end
    end
  end

  def parse_product(product)
    new_product = {name: product['product_name'],
                   url: product['url'],
                   price: product['price'],
                   rating: product['reviews']['review']['rating'],
                   ean: product['ean'],
                   product_number: product['productno'],
                   order_id: product['order_id']}
    @new_products.append(new_product)
  end
end
