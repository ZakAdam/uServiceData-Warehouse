require 'redis'

REDIS = Redis.new

def load_data
  File.readlines('./tags/redis-data.txt').each do |row|
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
  query = "FT.SEARCH supplierIndex @tags:{#{file_type.gsub(%r{[/\\\-.]}, '\\\\\0')}}@tags:{#{file_ending}}@tags:{#{charset.gsub(%r{[/\\\-.]}, '\\\\\0')}}@tags:{#{language}}@tags:{#{headers[0..4].join('|')}} RETURN 1 name"

  puts query
  print query

  results = REDIS.call(query.split)
  puts results

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
