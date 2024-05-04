# class representing Type Node
class Type
  include ActiveGraph::Node
  self.mapped_label_name = 'ns0__Type'

  id_property :neo_id
  property :rdfs__label
  property :uri
  property :ns0__fileEnding

  has_many :in, :suppliers, type: :ns0__HAS_fileType
end
