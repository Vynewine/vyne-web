class CreateOrderItems < ActiveRecord::Migration
  def change
    create_table :order_items do |t|
      t.references :order, index: true
      t.references :wine, index: true
      t.references :occasion, index: true
      t.references :type, index: true
      t.references :category
      t.string :specific_wine
      t.integer :quantity
      t.decimal :cost, index: true
      t.decimal :price, index: true
      t.timestamps
    end

    execute <<-SQL
      ALTER TABLE order_items
        ADD CONSTRAINT fk_order_items_orders
        FOREIGN KEY (order_id)
        REFERENCES orders(id)
    SQL

  end
end