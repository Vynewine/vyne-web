class AddStripeCustomerIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :stripe_id, :string
    rename_column :payments, :stripe, :stripe_card_id
  end
end
