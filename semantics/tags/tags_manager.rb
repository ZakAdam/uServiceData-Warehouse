require 'redis'

REDIS = Redis.new

def load_data
  File.readlines('redis-data.txt').each do |row|
    next if row[0] == '#' || row.strip.empty?

    REDIS.call(row.split)
  end
end

def get_supplier(file_ending, file_type, charset, language, headers)
  query = "FT.SEARCH supplierIndex @tags:{binary|en}"

  results = REDIS.call(query)
end
