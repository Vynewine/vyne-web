class CreatePreparations < ActiveRecord::Migration
  def change
    create_table :preparations do |t|
      t.string :name
      t.timestamps
    end

    create_table :food_items do |t|
      t.references :order_item, index: true
      t.references :food, index: true
      t.references :preparation, index: true
      t.timestamps
    end

    drop_table :foods_order_items

    db.execute "UPDATE foods SET parent = 4 where name = 'raw';"
    db.execute "DELETE FROM foods WHERE parent = 4;"
    db.execute "DELETE FROM foods WHERE name = 'preparation';"
    db.execute "INSERT INTO PREPARATIONS VALUES(1, 'grill & BBQ', NOW(),NOW());"
    db.execute "INSERT INTO PREPARATIONS VALUES(2, 'roasted', NOW(),NOW());"
    db.execute "INSERT INTO PREPARATIONS VALUES(3, 'fried & sautéed', NOW(),NOW());"
    db.execute "INSERT INTO PREPARATIONS VALUES(4, 'smoke', NOW(),NOW());"
    db.execute "INSERT INTO PREPARATIONS VALUES(5, 'poached & steamed', NOW(),NOW());"
    db.execute "INSERT INTO PREPARATIONS VALUES(6, 'raw', NOW(),NOW());"

  end

  def db
    ActiveRecord::Base.connection
  end
end