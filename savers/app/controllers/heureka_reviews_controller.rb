class HeurekaReviewsController < ApplicationController
  def new_review
    start_time = Time.now
    @new_reviews = []
    @new_products = []
    last_review_id = 1
    if Review.exists?
      last_review_id = Review.last.id + 1
    end
    parsed_reviews = params[:reviews]

    number_of_records = 0

    parsed_reviews['products']['product'].each do |product|
      parse_review(product)
      parse_product(product, last_review_id)
      last_review_id += 1
      number_of_records = number_of_records + 1
    end
    Review.insert_all(@new_reviews)
    Product.insert_all(@new_products)

    Log.create({log_type: "review", records_number: number_of_records, started_at: start_time, ended_at: Time.now})
  end

  private
  def parse_review(product)
    puts 'pomoc'
    puts product
    product['reviews'].each do |review|
      puts review.class
      puts "\n////\n"
      puts review
      review = review[1]      # odskusaj na viacej recenziach!!!
      #review = review['review']
      #puts review
      unix_time_integer = review['unix_timestamp'].to_i
      puts unix_time_integer
      converted_time = Time.at(review['unix_timestamp'].to_i)
      if review.key?('summary')
        @new_reviews.append({rating: review['rating'],
                             summary: review['summary'],
                             converted_timestamp: converted_time,
                             original_id: review['rating_id'],
                             unix_timestamp: review['unix_timestamp']})
      else
        @new_reviews.append({rating: review['rating'],
                             summary: nil,
                             converted_timestamp: converted_time,
                             original_id: review['rating_id'],
                             unix_timestamp: review['unix_timestamp']})
      end
    end
  end

  def parse_product(product, id)
    new_product = {name: product['product_name'],
                   url: product['url'],
                   price: product['price'],
                   rating: product['reviews']['review']['rating'],
                   ean: product['ean'],
                   product_number: product['productno'],
                   order_id: product['order_id'],
                   review_id: id}
    @new_products.append(new_product)
  end
end
