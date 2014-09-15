class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.integer :warehouse_id
      t.integer :client_id
      t.integer :advisor_id
      t.integer :wine_id
      t.integer :address_id
      t.integer :payment_id
      t.integer :status_id
      t.integer :quantity

      t.timestamps
    end
    add_index :orders, :client_id
    add_index :orders, :advisor_id
    add_index :orders, :warehouse_id
    add_index :orders, :wine_id
    add_index :orders, :address_id
    add_index :orders, :payment_id
    add_index :orders, :status_id
  end
end
