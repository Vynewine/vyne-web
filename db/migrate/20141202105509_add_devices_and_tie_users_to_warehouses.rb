class AddDevicesAndTieUsersToWarehouses < ActiveRecord::Migration
  def change
    create_table(:users_warehouses, :id => false) do |t|
      t.references :user
      t.references :warehouse
      t.datetime :deleted_at
    end

    add_index(:users_warehouses, [ :user_id, :warehouse_id ])
    add_index :users_warehouses, :deleted_at

    add_column :warehouses, :key, :string

    create_table :devices do |t|
      t.string :key
      t.text :registration_id
      t.datetime :deleted_at
    end

    add_index :devices, :deleted_at

    add_index :devices, :key, :unique => true

    create_table(:devices_warehouses, :id => false) do |t|
      t.references :device
      t.references :warehouse
      t.datetime :deleted_at
    end

    add_index :devices_warehouses, :deleted_at

  end
end
