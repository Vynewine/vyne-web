class CreateInventories < ActiveRecord::Migration
  def change
    create_table :inventories do |t|
      t.references :warehouse, index: true
      t.references :wine, index: true
      t.references :category, index: true
      t.integer :quantity

      t.timestamps
    end
  end
end
