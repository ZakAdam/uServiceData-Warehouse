# heureka_reviews_processor.rb

require 'sinatra'
require 'nokogiri'
require 'nori'
require 'rest-client'
require 'dotenv'

Dotenv.load

get '/' do
  'Hello world!'
end

post '/heureka_reviews/process' do
  #parsed_reviews = Nokogiri::XML.parse(params['reviews'])
  parser = Nori.new
  parsed_reviews = parser.parse(params['reviews'])
  #parsed_reviews = Nori.parse(params['reviews'])
  puts "\n\n\n\n"

  #parsed_reviews['products']['product'].each do |product|
  #  puts product['product_name']
  #end

  result = RestClient.post "#{ENV.fetch("HEUREKA_URL")}/heureka_reviews/save", :reviews => parsed_reviews

  puts result
end
