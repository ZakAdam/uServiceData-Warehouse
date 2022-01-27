class CreateTrackingDetailDimensionTable < ActiveRecord::Migration[6.1]
  def change
    create_table :tracking_details do |t|
      t.integer :service
      t.integer :add_service_1
      t.integer :add_service_2
      t.integer :add_service_3
      t.text :info_text
      t.integer :weight
      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }
    end
  end
end
