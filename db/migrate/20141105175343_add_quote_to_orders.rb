class AddQuoteToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :delivery_quote, :json
  end
end
