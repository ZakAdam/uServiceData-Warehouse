class CreateDatesDimensionTable < ActiveRecord::Migration[6.1]
  def change
    create_table :dates do |t|
      t.date :delivery_date
      t.date :invoice_date
      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }
    end
  end
end
