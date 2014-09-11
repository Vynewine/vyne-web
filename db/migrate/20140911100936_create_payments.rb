class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.integer :user_id
      t.integer :brand
      t.string :number
      t.string :stripe

      t.timestamps
    end
  end
end
