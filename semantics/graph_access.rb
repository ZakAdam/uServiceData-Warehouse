# File testing options for Neo4j querying
require 'active_graph'
require 'neo4j-ruby-driver'
Dir['./models/*.rb'].each { |file| require file }

ActiveGraph::Base.driver = Neo4j::Driver::GraphDatabase.driver('bolt://localhost:7687', Neo4j::Driver::AuthTokens.basic('neo4j','postgres'))

class QueryDB
  def process(file_ending, charst)
    puts 'More'
    lol = Supplier.find_by(rdfs__label: 'GLS')
    puts lol.inspect
    #puts lol.columns.each_rel { |r| puts r.inspect }
    #puts lol.types.inspect
    puts 'gadzo'

    result = ActiveGraph::Base.query("MATCH (charset:ns0__Charset)<-[h1:ns0__HAS_charSet]-(supplier:ns0__Supplier)
                                    WHERE charset.rdfs__label = 'UTF-8'
                                    RETURN supplier").first
    puts result.inspect
    puts 'RETURN'
    puts result.values.first.inspect

    return result.values.first.inspect.to_s
  end

  def get_by_charset(charset)
    Charset.find_by(rdfs__label: charset.upcase).suppliers(:s).pluck(:s)
  end

  def get_by_ending(file_ending)
    Type.find_by(ns0__fileEnding: file_ending).suppliers(:s).pluck(:s)
  end
end
