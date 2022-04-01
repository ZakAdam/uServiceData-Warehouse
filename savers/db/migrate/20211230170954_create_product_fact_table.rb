class CreateProductFactTable < ActiveRecord::Migration[6.1]
  def change
    create_table :products do |t|
      t.string :name
      t.string :url
      t.decimal :price
      t.integer :rating
      t.string :ean
      t.string :product_number
      t.bigint :order_id
      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }
    end
  end
end
