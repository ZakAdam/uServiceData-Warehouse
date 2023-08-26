# File for parsing content of xml files.
# Parsed data are used to determine data origin using given headers/keys and ontology.
require 'nokogiri'

def load_keys
  doc = File.open(FILE) { |f| Nokogiri::XML(f) }
  doc.search('*').map(&:name).uniq
end

FILE = '/home/adam/Desktop/FIIT/DP/files/Heureka/mensie.xml'
puts load_keys
