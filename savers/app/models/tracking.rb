class Tracking < ApplicationRecord
  has_one :depot
  has_one :consignee
  has_one :service
end
