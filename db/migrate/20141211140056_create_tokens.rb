class CreateTokens < ActiveRecord::Migration
  def change
    create_table :tokens do |t|
      t.string :key
      t.string :access_token
      t.string :refresh_token
      t.datetime :expires_at

      t.timestamps
    end

    db.execute "INSERT INTO tokens VALUES(1, 'google_coordinate', '', '', null, NOW(),NOW());"

  end

  def db
    ActiveRecord::Base.connection
  end
end
