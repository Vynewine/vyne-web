class CreateAddressesUsers < ActiveRecord::Migration
  def change
    create_join_table :addresses, :users do |t|
      t.references :address, index: true
      t.references :user, index: true
      t.timestamps
    end
  end
end
