class CreatePaymentMethodsDimensionTable < ActiveRecord::Migration[6.1]
  def change
    create_table :payment_methods do |t|
      t.string :type
      t.timestamps
    end
  end
end
