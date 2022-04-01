ActiveRecord::Base.logger.level = 1

Rails.application.config.filter_parameters += [:file]