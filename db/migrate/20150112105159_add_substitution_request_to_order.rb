class AddSubstitutionRequestToOrder < ActiveRecord::Migration
  def up
    add_column :orders, :advisory_completed_at, :datetime
    add_column :orders, :cancellation_note, :text
    add_column :order_items, :substitution_requested_at, :datetime
    add_column :order_items, :substitution_status, :integer, index: true, default: 0
    add_column :order_items, :substitution_request_note, :text
    add_column :order_items, :advisory_note, :text

    db.execute "INSERT INTO statuses VALUES(11, 'advised', NOW(),NOW());"
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
  end

  def db
    ActiveRecord::Base.connection
  end
end
