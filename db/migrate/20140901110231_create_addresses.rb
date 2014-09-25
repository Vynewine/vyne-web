class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.string :street
      t.string :detail
      t.string :postcode

      t.timestamps
    end
    add_index :addresses, :detail
    add_index :addresses, :postcode
  end
end
