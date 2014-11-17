class AddCoordinanceToAddress < ActiveRecord::Migration
  def change
    add_column :addresses, :coordinates, :point
    rename_column :addresses, :street, :line_1
    add_column :addresses, :line_2, :string
    add_column :addresses, :company_name, :string
    add_column :addresses, :country, :string
    add_column :addresses, :city, :string
    remove_column :addresses, :detail
  end
end
