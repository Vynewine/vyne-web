class CleanupPromotions < ActiveRecord::Migration
  def change

    remove_column :user_promotions, :referral_code_id
    remove_column :user_promotions, :friend_id

    remove_column :referrals, :promotion_id
    remove_column :referrals, :user_id

    drop_table :referral_codes
    add_column :promotions, :description, :text
    add_column :promotions, :new_accounts_only, :boolean, default: true

  end
end
