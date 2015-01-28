class MoveWarehouseToDevice < ActiveRecord::Migration
  def change
    add_reference :devices, :warehouse, index: true
    db.execute 'UPDATE devices AS d SET warehouse_id = w.warehouse_id FROM devices_warehouses w WHERE d.id = w.device_id'
    drop_table :devices_warehouses

    execute <<-SQL
      ALTER TABLE devices
        ADD CONSTRAINT fk_devices_warehouse
        FOREIGN KEY (warehouse_id)
        REFERENCES warehouses(id)
    SQL

  end

  def db
    ActiveRecord::Base.connection
  end
end
