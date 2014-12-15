class AddDeliveryTypeToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :delivery_provider, :string
    add_column :orders, :delivery_courier, :json
  end
end
