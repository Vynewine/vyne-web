class AddCategoryAvailabilityToWarehouse < ActiveRecord::Migration
  def change
    add_column :warehouses, :house_available, :boolean, :default => true
    add_column :warehouses, :reserve_available, :boolean, :default => true
    add_column :warehouses, :fine_available, :boolean, :default => true
    add_column :warehouses, :cellar_available, :boolean, :default => true
  end
end
