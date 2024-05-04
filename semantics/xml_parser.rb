# File for parsing content of xml files.
# Parsed data are used to determine data origin using given headers/keys and ontology.
require 'nokogiri'
#require 'rdf'
#require 'linkeddata'
#require 'rdf/ntriples'


def load_keys
  doc = File.open(FILE) { |f| Nokogiri::XML(f) }
  doc.search('*').map(&:name).uniq
end

FILE = '/home/adam/Desktop/FIIT/uServiceData-Warehouse/files/test_files/Heureka/product-review-muziker-sk.xml'
puts load_keys

=begin
# https://github.com/ruby-rdf/rdf
RDF::Reader.open("https://ruby-rdf.github.io/rdf/etc/doap.nt") do |reader|
  reader.each_statement do |statement|
    puts statement.inspect
  end
end


graph = RDF::Graph.load("https://ruby-rdf.github.io/rdf/etc/doap.nt")
query = RDF::Query.new({
                         person: {
                           RDF.type  => RDF::Vocab::FOAF.Person,
                           RDF::Vocab::FOAF.name => :name,
                           RDF::Vocab::FOAF.mbox => :email,
                         }
                       }, **{})

query.execute(graph) do |solution|
  puts "name=#{solution.name} email=#{solution.email}"
end
=end
