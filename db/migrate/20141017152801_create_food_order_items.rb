class CreateFoodOrderItems < ActiveRecord::Migration
  def change
    create_join_table :foods, :order_items do |t|
      t.references :food, index: true
      t.references :order_item, index: true
      t.timestamps
    end
  end
end