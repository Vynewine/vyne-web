class CleanupStatuses < ActiveRecord::Migration
  def change
    db.execute "UPDATE statuses SET label = 'in transit' WHERE id = 5;"
    db.execute "DELETE FROM statuses WHERE id = 9;"
  end

  def db
    ActiveRecord::Base.connection
  end
end
