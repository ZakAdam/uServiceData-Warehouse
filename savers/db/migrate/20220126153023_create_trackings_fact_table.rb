class CreateTrackingsFactTable < ActiveRecord::Migration[6.1]
  def change
    create_table :trackings do |t|
      t.string :parcel_no
      t.integer :scan_code
      t.datetime :date
      t.string :customer_reference
      t.references :depot, foreign_key: { to_table: :depots }, index: true
      t.references :consignee, foreign_key: { to_table: :consignees }, index: true
      t.references :tracking_detail, foreign_key: { to_table: :tracking_details }, index: true

      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }
    end
  end
end
