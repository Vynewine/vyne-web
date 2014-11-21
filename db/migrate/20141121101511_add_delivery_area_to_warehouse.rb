class AddDeliveryAreaToWarehouse < ActiveRecord::Migration
  def change
    add_column :warehouses, :delivery_area, :polygon
  end
end
