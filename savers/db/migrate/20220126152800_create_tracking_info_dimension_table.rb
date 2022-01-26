class CreateTrackingInfoDimensionTable < ActiveRecord::Migration[6.1]
  def change
    create_table :tracking_infos do |t|
      t.string :customer_reference
      t.text :info_text
      t.integer :weight
      t.timestamps
    end
  end
end
