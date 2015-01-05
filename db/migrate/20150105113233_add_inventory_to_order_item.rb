class AddInventoryToOrderItem < ActiveRecord::Migration
  def change
    add_reference :order_items, :inventory, index: true

    execute <<-SQL
      ALTER TABLE order_items
        ADD CONSTRAINT fk_order_item_inventory
        FOREIGN KEY (inventory_id)
        REFERENCES inventories(id)
    SQL
  end
end
