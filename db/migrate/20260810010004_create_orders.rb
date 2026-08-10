class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_enum :order_state, %w[pending in_progress created done sent delivered cancelled failed], if_not_exists: true

    create_table :orders, if_not_exists: true do |t|
      t.references :tenant, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.enum :state, enum_type: "order_state", default: "pending", null: false

      t.timestamps
    end

    add_index :orders, :tenant_id, if_not_exists: true
  end
end
