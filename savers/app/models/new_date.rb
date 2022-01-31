class NewDate < ApplicationRecord
  self.table_name = 'dates'

  belongs_to :invoice
end
