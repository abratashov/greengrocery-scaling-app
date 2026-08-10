class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products, if_not_exists: true do |t|
      t.references :tenant, null: false, foreign_key: true
      t.string :name, null: false
      t.decimal :price, precision: 10, scale: 2, null: false, default: 0
      t.integer :amount, null: false, default: 0

      t.timestamps
    end

    add_index :products, :tenant_id, if_not_exists: true
  end
end
