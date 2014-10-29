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

    execute <<-SQL
      ALTER TABLE inventories
        ADD CONSTRAINT fk_inventories_warehouses
        FOREIGN KEY (warehouse_id)
        REFERENCES warehouses(id)
    SQL

    execute <<-SQL
      ALTER TABLE inventories
        ADD CONSTRAINT fk_inventories_wines
        FOREIGN KEY (wine_id)
        REFERENCES wines(id)
    SQL

    execute <<-SQL
      ALTER TABLE inventories
        ADD CONSTRAINT fk_inventories_categories
        FOREIGN KEY (category_id)
        REFERENCES categories(id)
    SQL
  end
end
