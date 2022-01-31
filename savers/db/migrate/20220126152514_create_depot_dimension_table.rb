class CreateDepotDimensionTable < ActiveRecord::Migration[6.1]
  def change
    create_table :depots do |t|
      t.integer :depot_code
      t.string :depot_name
      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }
    end
  end
end
