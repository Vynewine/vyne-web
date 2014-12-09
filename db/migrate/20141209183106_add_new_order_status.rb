class AddNewOrderStatus < ActiveRecord::Migration
  def change
    db.execute "INSERT INTO statuses VALUES(8, 'packing', NOW(),NOW());"
  end

  def db
    ActiveRecord::Base.connection
  end
end
