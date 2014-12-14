class AddStatusesToOrder < ActiveRecord::Migration
  def change
    db.execute "INSERT INTO statuses VALUES(9, 'transit', NOW(),NOW());"
    db.execute "INSERT INTO statuses VALUES(10, 'created', NOW(),NOW());"
  end

  def db
    ActiveRecord::Base.connection
  end
end
