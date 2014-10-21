class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.references :warehouse, index: true
      t.references :client, index: true
      t.references :advisor, index: true
      t.references :address, index: true
      t.references :payment, index: true
      t.references :status, index: true
      t.string :delivery_token
      t.json :information
      t.json :delivery_status

      t.timestamps
    end
  end
end
