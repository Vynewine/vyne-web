class AddActiveFlagForWarehouses < ActiveRecord::Migration
  def change
    add_column :warehouses, :active, :boolean
    db.execute 'update warehouses set active = true;'
  end

  def db
    ActiveRecord::Base.connection
  end
end
