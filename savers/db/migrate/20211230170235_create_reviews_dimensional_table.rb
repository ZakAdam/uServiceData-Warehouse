class CreateReviewsDimensionalTable < ActiveRecord::Migration[6.1]
  def change
    create_table :reviews do |t|
      t.integer :rating
      t.text :summary
      t.text :pros
      t.text :cons
      t.timestamp :converted_timestamp
      t.bigint :original_id
      t.string :unix_timestamp
      t.references :product, foreign_key: { to_table: :products }, index: true
      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }
    end
  end
end
