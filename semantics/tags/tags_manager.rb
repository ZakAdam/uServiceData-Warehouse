require 'redis'
require 'sinatra'
require 'dotenv'
require 'json'

#REDIS = Redis.new
#REDIS = Redis.new(url: ENV['REDIS_SIDEKIQ_URL'])
REDIS = Redis.new(host: ENV['REDIS_HOST'], port: ENV['REDIS_PORT'])


get '/' do
  'Hello world!'
end

post '/tags/process' do
  data = JSON.parse(params[:data])

  # supplier = get_supplier_by_tags(data[:file_ending], data[:mime_type], data[:charset], data[:language], data[:headers])
  supplier = get_supplier_by_tags(data['file_ending'], data['mime_type'], data['charset'], data['language'], data['headers'])
  # path = get_path_by_tags(supplier, data[:conditions])

  supplier
end

private

def load_data
  File.readlines('redis-data.txt').each do |row|
    next if row[0] == '#' || row.strip.empty?

    REDIS.call(row.split)
  end
end

def get_supplier_by_tags(file_ending, file_type, charset, language, headers)
  begin
    REDIS.call('FT.INFO supplierIndex'.split)
  rescue Redis::CommandError => e
    puts "Index is missing => #{e}"
    puts 'Creating index...'
    load_data
  end

  headers = headers.map { |s| s.gsub(' ', '_') }
  #query = "FT.SEARCH supplierIndex @tags:{binary|en}"

  # query = "FT.SEARCH supplierIndex @tags:{#{file_ending}|#{file_type.gsub('-', '\-')}|#{charset.gsub('-', '\-')}|#{language}|#{headers[0..4].join('|')}} RETURN 1 name WITHSCORES"
  query = "FT.SEARCH supplierIndex @tags:{#{file_type.gsub(%r{[/\\\-.]}, 
                                                           '\\\\\0')}}@tags:{#{file_ending}}@tags:{#{charset.gsub(%r{[/\\\-.]},
                                                           '\\\\\0')}}@tags:{#{language}}@tags:{#{headers[0..4].join('|')}} RETURN 1 name"

  results = REDIS.call(query.split)

  puts "Tags identified supplier: #{results[2][1]}"
  results[2][1].downcase
end

def get_path_by_tags(supplier, conditions)
  query = "MGET #{conditions.join(' ')} #{supplier}"

  path = REDIS.call(query.split).compact
  puts "Path created by tags: #{path}"
  path
end
