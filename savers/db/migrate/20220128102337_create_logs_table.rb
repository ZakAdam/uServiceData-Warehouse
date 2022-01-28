class CreateLogsTable < ActiveRecord::Migration[6.1]
  def change
    create_table :logs do |t|
      t.string :log_type
      t.integer :records_number
      t.datetime :started_at
      t.datetime :ended_at

      t.timestamps
    end
  end
end
