class AddShutlRegistrationToWarehouse < ActiveRecord::Migration
  def change
    add_column :warehouses, :registered_with_shutl, :boolean
  end
end
