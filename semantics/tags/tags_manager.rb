require 'redis'
require 'sinatra'
require 'dotenv'
require 'json'

REDIS = Redis.new(host: ENV['REDIS_HOST'], port: ENV['REDIS_PORT'])

get '/' do
  'Hello world!'
end

post '/tags/process' do
  data = JSON.parse(params[:data])

  supplier = get_supplier_by_tags(data['file_ending'], data['mime_type'], data['charset'], data['language'], data['headers'])
  path = get_path_by_tags(supplier, data['conditions'])

  puts "Tags identified supplier as: #{supplier}"
  path
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

  if file_ending.empty?
    query_data = "#{file_type.gsub(%r{[/\\\-.]}, '\\\\\0')}|#{charset.gsub(%r{[/\\\-.]}, '\\\\\0')}|#{language}|#{headers[0..6].join('|')}"
    query_data_raw = "#{file_type}|#{charset}|#{language}|#{headers[0..6].join('|')}".downcase
  else
    query_data = "#{file_type.gsub(%r{[/\\\-.]}, '\\\\\0')}|#{file_ending}|#{charset.gsub(%r{[/\\\-.]}, '\\\\\0')}|#{language}|#{headers[0..6].join('|')}"
    query_data_raw = "#{file_type}|#{file_ending}|#{charset}|#{language}|#{headers[0..6].join('|')}".downcase
  end

  query = "FT.SEARCH supplierIndex @tags:{#{query_data}} PAYLOAD #{query_data_raw} WITHSCORES SCORER HITS_SCORER"

  puts query

  results = REDIS.call(query.split)

  puts results

  get_supplier_name(results[3])
end

def get_path_by_tags(supplier, conditions)
  query = "MGET #{conditions.join(' ')} #{supplier}"

  path = REDIS.call(query.split).compact
  puts "Path created by tags: #{path}"
  path.to_s
end

def get_supplier_name(array)
  new_hash = {}

  array.each_slice(2) do |key, value|
    new_hash[key.to_sym] = value
  end

  puts "Tags identified supplier: #{new_hash[:name].downcase}"
  new_hash[:name].downcase
end
