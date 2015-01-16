class AddSubstitutionRequestToOrder < ActiveRecord::Migration
  def up
    add_column :orders, :advisory_completed_at, :datetime
    add_column :orders, :cancellation_note, :text
    add_column :order_items, :substitution_requested_at, :datetime
    add_column :order_items, :substitution_status, :integer, index: true, default: 0
    add_column :order_items, :substitution_request_note, :text
    add_column :order_items, :advisory_note, :text
    add_column :categories, :price_min, :numeric
    add_column :categories, :price_max, :numeric
    add_column :orders, :delivery_price, :numeric

    db.execute "INSERT INTO statuses VALUES(11, 'advised', NOW(),NOW());"

    db.execute 'UPDATE categories SET price_min = 10.00 WHERE id = 1;'
    db.execute 'UPDATE categories SET price_max = 15.00 WHERE id = 1;'

    db.execute 'UPDATE categories SET price_min = 15.00 WHERE id = 2;'
    db.execute 'UPDATE categories SET price_max = 20.00 WHERE id = 2;'

    db.execute 'UPDATE categories SET price_min = 20.00 WHERE id = 3;'
    db.execute 'UPDATE categories SET price_max = 30.00 WHERE id = 3;'

    db.execute 'UPDATE categories SET price_min = 30.00 WHERE id = 4;'
    db.execute 'UPDATE categories SET price_max = 50.00 WHERE id = 4;'

    db.execute 'UPDATE inventories SET category_id = null WHERE cost < 10;'
    db.execute 'UPDATE inventories SET category_id = 1 WHERE cost >= 10 and cost <= 15;'
    db.execute 'UPDATE inventories SET category_id = 2 WHERE cost >= 15.01 and cost <= 20;'
    db.execute 'UPDATE inventories SET category_id = 3 WHERE cost >= 20.01 and cost <= 30;'
    db.execute 'UPDATE inventories SET category_id = 4 WHERE cost >= 30.01 and cost <= 50;'

  end

  def down

    db.execute 'UPDATE orders SET status_id = 8 WHERE status_id = 11;'
    db.execute 'DELETE FROM statuses WHERE id = 11;'

    remove_column :orders, :advisory_completed_at
    remove_column :orders, :cancellation_note
    remove_column :order_items, :substitution_requested_at
    remove_column :order_items, :substitution_status
    remove_column :order_items, :substitution_request_note
    remove_column :order_items, :advisory_note
    remove_column :categories, :price_min
    remove_column :categories, :price_max
    remove_column :orders, :delivery_price
  end

  def db
    ActiveRecord::Base.connection
  end
end
