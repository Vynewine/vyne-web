class CreateInventories < ActiveRecord::Migration
  def change
    create_table :inventories do |t|
      t.references :warehouse, index: true
      t.references :wine, index: true
      t.references :category, index: true
      t.decimal :cost, index: true
      t.integer :quantity, index: true
      t.string :vendor_sku, inex: true
      t.timestamps
    end
  end
end
