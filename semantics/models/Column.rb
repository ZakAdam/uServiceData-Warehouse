# class representing Column Node
class Column
  include ActiveGraph::Node
  self.mapped_label_name = 'ns0__Column'

  id_property :neo_id
  property :rdfs__label
  property :uri
  property :ns0__columnType
end
