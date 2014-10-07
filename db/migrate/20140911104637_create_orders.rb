class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.references :warehouse, index: true
      t.references :client, index: true
      t.references :advisor, index: true
      t.references :wine, index: true
      t.references :address, index: true
      t.references :payment, index: true
      t.references :status, index: true
      t.integer :quantity
      t.string :info

      t.timestamps
    end
    add_index :orders, :quantity
  end
end
