class CreateCustomersDimensionTable < ActiveRecord::Migration[6.1]
  def change
    create_table :customers do |t|
      t.string :name
      t.string :city
      t.string :zipcode
      t.string :address
      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }
    end
  end
end
