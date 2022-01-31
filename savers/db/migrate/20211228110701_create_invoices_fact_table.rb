class CreateInvoicesFactTable < ActiveRecord::Migration[6.1]
  def change
    create_table :invoices do |t|
      t.references :customer, foreign_key: { to_table: :customers }, index: true
      t.references :date, foreign_key: { to_table: :dates }, index: true
      t.references :carrier, foreign_key: { to_table: :carriers }, index: true
      t.references :country, foreign_key: { to_table: :countries }, index: true
      t.decimal :price
      t.decimal :fees
      t.decimal :cash_on_delivery
      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }
    end
  end
end
