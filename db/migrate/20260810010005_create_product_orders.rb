class CreateProductOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :product_orders, if_not_exists: true do |t|
      t.references :order, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :amount, null: false, default: 1
      t.decimal :total_price, precision: 10, scale: 2, null: false, default: 0

      t.timestamps
    end

    add_index :product_orders, :order_id, if_not_exists: true
    add_index :product_orders, :product_id, if_not_exists: true
  end
end
