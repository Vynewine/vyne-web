class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.references :user, index: true
      t.integer :brand
      t.string :number
      t.string :stripe

      t.timestamps
    end
    add_index :payments, :number
  end
end
