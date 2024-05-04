# class representing Supplier Node
class Supplier
  include ActiveGraph::Node
  self.mapped_label_name = 'ns0__Supplier'

  id_property :neo_id
  property :rdfs__label
  property :uri

  has_many :out, :columns, type: :ns0__fileElements
  has_one :out, :type, type: :ns0__HAS_fileType
  has_many :out, :endpoints, type: :ns0__HAS_endpoint
  has_one :out, :charset, type: :ns0__HAS_charSet
end
