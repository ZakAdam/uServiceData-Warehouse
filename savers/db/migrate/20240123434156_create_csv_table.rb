class CreateCsvTable < ActiveRecord::Migration[6.1]
  def change
    create_table :csv_data do |t|
      t.string :row

      t.timestamps
    end
  end
end
