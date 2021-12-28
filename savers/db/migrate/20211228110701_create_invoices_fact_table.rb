class CreateInvoicesFactTable < ActiveRecord::Migration[6.1]
  def change
    create_table :invoices do |t|
      t.references :customer, foreign_key: { to_table: :customers }, index: true
      t.references :date, foreign_key: { to_table: :date }, index: true
      t.references :carrier, foreign_key: { to_table: :carrier }, index: true

      t.timestamps
    end
  end
end
