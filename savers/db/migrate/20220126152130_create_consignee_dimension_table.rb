class CreateConsigneeDimensionTable < ActiveRecord::Migration[6.1]
  def change
    create_table :consignees do |t|
      t.string :name
      t.string :zipcode
      t.integer :country_code
      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }
    end
  end
end
