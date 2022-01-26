class CreateServiceDimensionTable < ActiveRecord::Migration[6.1]
  def change
    create_table :services do |t|
      t.integer :service
      t.integer :add_service_1
      t.integer :add_service_2
      t.integer :add_service_3
      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }
    end
  end
end
