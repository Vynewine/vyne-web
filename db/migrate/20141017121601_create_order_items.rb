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
  end
end