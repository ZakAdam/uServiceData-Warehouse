class Setting < ApplicationRecord
  def options=(options)
    self[:options] = JSON.parse(options) if options.present?
  end
end
