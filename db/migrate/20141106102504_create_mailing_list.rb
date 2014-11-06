class CreateMailingList < ActiveRecord::Migration
  def up
    create_table :mailing_lists do |t|
      t.string :name
      t.string :key
      t.timestamps
    end

    create_table :subscribers do |t|
      t.references :mailing_list, index: true
      t.string :email
      t.json :info
      t.timestamps
    end

    execute <<-SQL
      ALTER TABLE subscribers
        ADD CONSTRAINT fk_subscriber_mailing_lists
        FOREIGN KEY (mailing_list_id)
        REFERENCES mailing_lists(id)
    SQL

    db.execute "INSERT INTO mailing_lists VALUES(1, 'Coming Soon in your area', 'coming-soon', NOW(),NOW());"

  end

  def down
    drop_table :subscribers
    drop_table :mailing_lists
  end

  def db
    ActiveRecord::Base.connection
  end
end
