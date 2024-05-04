class CreateRowFactTable < ActiveRecord::Migration[6.1]
  def change
    create_table :rows do |t|
      t.text :row
      t.string :supplier
      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }
    end
  end
end
