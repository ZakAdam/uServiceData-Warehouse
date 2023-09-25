class CreateSettingsTable < ActiveRecord::Migration[6.1]
  def change
    create_table :settings do |t|
      t.string :name
      t.string :username
      t.jsonb "options", default: {}

      t.timestamps
    end
  end
end
