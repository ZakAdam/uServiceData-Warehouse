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

  query = "FT.SEARCH supplierIndex @tags:{#{file_ending}|#{file_type.gsub('-', '\-')}|#{charset}|#{language}|#{headers[0..4].join('|')}}"

  puts query

  results = REDIS.call(query.split)
  puts results
end
