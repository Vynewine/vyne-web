class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.string :street
      t.string :detail
      t.string :postcode

      t.timestamps
    end
  end
end
