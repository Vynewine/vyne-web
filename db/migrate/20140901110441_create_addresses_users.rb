class CreateAddressesUsers < ActiveRecord::Migration
  def change
    create_join_table :addresses, :users do |t|
      t.index :address_id
      t.index :user_id
      t.timestamps
    end
  end
end
