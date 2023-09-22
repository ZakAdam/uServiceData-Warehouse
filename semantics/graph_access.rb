# File testing options for Neo4j querying
require 'active_graph'
require 'neo4j-ruby-driver'

ActiveGraph::Base.driver = Neo4j::Driver::GraphDatabase.driver('bolt://localhost:7687', Neo4j::Driver::AuthTokens.basic('neo4j','postgres'))

# class representing Supplier Node
class Supplier
  include ActiveGraph::Node
  self.mapped_label_name = 'ns0__Supplier'

  id_property :neo_id
  property :rdfs__label
  property :uri

  has_many :out, :columns, type: :ns0__fileElements
  has_one :out, :types, type: :ns0__fileType
end

# class representing Column Node
class Column
  include ActiveGraph::Node
  self.mapped_label_name = 'ns0__Column'

  id_property :neo_id
  property :rdfs__label
  property :uri
  property :ns0__columnType
end

# class representing Type Node
class Type
  include ActiveGraph::Node
  self.mapped_label_name = 'ns0__Type'

  id_property :neo_id
  property :rdfs__label
  property :uri
  property :ns0__fileEnding
end

puts 'More'
lol = Supplier.find_by(rdfs__label: 'GLS')
puts lol.inspect
puts lol.columns.each_rel { |r| puts r.inspect }
puts lol.types.inspect
puts 'gadzo'
