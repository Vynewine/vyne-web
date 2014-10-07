class AddFieldsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :mobile, :string
    add_column :users, :address_id, :integer
    add_column :users, :active, :boolean
    add_column :users, :code, :string
    add_index :users, :address_id
  end
end
