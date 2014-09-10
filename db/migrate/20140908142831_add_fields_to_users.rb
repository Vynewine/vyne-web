class AddFieldsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :name, :string
    add_column :users, :mobile, :string
    add_column :users, :address_id, :integer
  end
end
