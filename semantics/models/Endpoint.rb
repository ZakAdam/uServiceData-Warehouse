# class representing Endpoint Node
class Endpoint
  include ActiveGraph::Node
  self.mapped_label_name = 'ns0__Endpoint'

  id_property :neo_id
  property :rdfs__label
  property :uri
  property :ns0__url
  property :ns0__method
  property :ns0__condition

  has_many :out, :endpoints, type: :ns0__HAS_endpoint
end
