require 'redis'

REDIS = Redis.new

def load_data
  File.readlines('redis-data.txt').each do |row|
    next if row[0] == '#' || row.strip.empty?

    REDIS.call(row.split)
  end
end

def get_supplier_by_tags(file_ending, file_type, charset, language, headers)
  headers = headers.map { |s| s.gsub(' ', '_') }
  #query = "FT.SEARCH supplierIndex @tags:{binary|en}"

  puts headers

  query = "FT.SEARCH supplierIndex @tags:{#{file_ending}|#{file_type.gsub('-', '\-')}|#{charset}|#{language}|#{headers[0..4].join('|')}} RETURN 1 name"

  puts query

  results = REDIS.call(query.split)
  puts "Tags identified supplier: #{results[2][1]}"
  results[2][1].downcase
end

def get_path_by_tags(supplier, conditions)
  query = "MGET #{conditions.join(' ')} #{supplier}"
  puts query

  path = REDIS.call(query.split).compact
  puts "Path created by tags: #{path}"
  path
end
