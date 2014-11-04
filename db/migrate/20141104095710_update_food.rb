class UpdateFood < ActiveRecord::Migration

  def up
    db.execute "UPDATE foods SET parent = 4 where name = 'raw';"
  end

  def db
    ActiveRecord::Base.connection
  end
end