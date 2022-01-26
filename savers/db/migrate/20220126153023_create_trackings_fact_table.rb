class CreateTrackingsFactTable < ActiveRecord::Migration[6.1]
  def change
    create_table :trackings do |t|
      t.string :parcel_no
      t.integer :scan_code
      t.datetime :date
      t.references :depot, foreign_key: { to_table: :depots }, index: true
      t.references :consignee, foreign_key: { to_table: :consignees }, index: true
      t.references :service, foreign_key: { to_table: :services }, index: true
      t.references :tracking_info, foreign_key: { to_table: :tracking_infos }, index: true

      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }
    end
  end
end
