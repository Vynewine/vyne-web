class AddChargeAndRefundDetailsToProducts < ActiveRecord::Migration
  def change
    add_column :orders, :charge_id, :string
    add_column :orders, :refund_id, :string
  end
end
