class CreateWarehouses < ActiveRecord::Migration
  def change
    create_table :warehouses do |t|
      t.string :title
      t.string :email, null: false, default: ""
      t.references :address, index: true
      t.timestamps
    end
  end
end
