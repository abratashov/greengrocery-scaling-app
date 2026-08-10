class CreatePayments < ActiveRecord::Migration[8.1]
  def change
    create_enum :payment_state, %w[pending in_progress paid failed], if_not_exists: true

    create_table :payments, if_not_exists: true do |t|
      t.references :order, null: false, foreign_key: true
      t.decimal :total_price, precision: 10, scale: 2, null: false, default: 0
      t.enum :state, enum_type: "payment_state", default: "pending", null: false

      t.timestamps
    end

    add_index :payments, :order_id, if_not_exists: true
  end
end
