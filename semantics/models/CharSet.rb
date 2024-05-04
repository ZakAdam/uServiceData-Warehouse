# class representing charSet Node
class Charset
  include ActiveGraph::Node
  self.mapped_label_name = 'ns0__Charset'

  id_property :neo_id
  property :rdfs__label
  property :uri
  property :ns0__charSet

  has_many :in, :suppliers, type: :ns0__HAS_charSet
end
