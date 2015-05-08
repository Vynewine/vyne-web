class CreateCart < ActiveRecord::Migration
  def up
    create_table :carts do |t|
      t.references :warehouse, index: true
      t.string :client
      t.string :postcode
      t.references :address, index: true
      t.references :payment, index: true
      t.integer :delivery_type
      t.datetime :delivery_expires_on
      t.json :delivery_schedule
      t.datetime :expire_on, index: true
      t.datetime :merged_at, index: true
      t.datetime :deleted_at, index: true
      t.timestamps
    end

    create_table :cart_items do |t|
      t.references :cart, index: true, null: false
      t.references :occasion, index: true
      t.references :type, index: true
      t.references :category
      t.string :specific_wine
      t.integer :quantity
      t.datetime :deleted_at, index: true
      t.timestamps
    end

    add_reference :food_items, :cart_item

    execute <<-SQL
      ALTER TABLE cart_items
        ADD CONSTRAINT fk_cart_items_carts
        FOREIGN KEY (cart_id)
        REFERENCES carts(id)
    SQL

    execute <<-SQL
      ALTER TABLE food_items
        ADD CONSTRAINT fk_food_items_cart_items
        FOREIGN KEY (cart_item_id)
        REFERENCES cart_items(id)
    SQL

  end

  def down
    remove_reference :food_items, :cart_item
    drop_table :cart_items
    drop_table :carts
  end
end
