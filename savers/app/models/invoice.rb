class Invoice < ApplicationRecord
  has_one :customer
  has_one :new_date
  has_one :country
end

