class AddOpeningDateToWarehouse < ActiveRecord::Migration
  def change
    add_column :warehouses, :active_from, :datetime
  end
end
