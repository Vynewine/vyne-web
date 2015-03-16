class ChangePromotions < ActiveRecord::Migration
  def up
    create_table :promotion_codes do |t|
      t.references :promotion, index: true
      t.string :code
      t.boolean :active, default: true
      t.datetime :expiration_date
      t.integer :redeem_count_limit, default: 0, null: false
      t.integer :category, null: false
      t.datetime :deleted_at, index: true
      t.timestamps
    end

    create_table :user_promotion_codes do |t|
      t.references :promotion_code, index: true
      t.references :user, index: true
      t.datetime :deleted_at, index: true
      t.timestamps
    end

    add_reference :user_promotions, :promotion_code
    add_reference :referrals, :promotion_code

    add_column :referrals, :referred_user_id, :integer
    add_column :referrals, :existing_user_id, :integer
    add_column :promotions, :free_delivery, :boolean
    add_column :promotions, :extra_bottle, :boolean
    add_column :promotions, :bottle_category, :integer

    rename_column :warehouse_promotions, :price_range_min, :extra_bottle_price_min
    rename_column :warehouse_promotions, :price_range_max, :extra_bottle_price_max

    # TODO: 1. Migrate referral_codes to promotion_codes and drop referral_codes 2. Migrate user_promotions to referrals
    # Drop from referrals: promotion_id, user_id,
    # Drop from user_promotions: referral_code_id
    # Drop referral_codes

  end

  def down
    remove_reference :user_promotions, :promotion_code
    remove_reference :referrals, :promotion_code

    remove_column :referrals, :referred_user_id
    remove_column :referrals, :existing_user_id
    remove_column :promotions, :free_delivery
    remove_column :promotions, :extra_bottle
    remove_column :promotions, :bottle_category

    rename_column :warehouse_promotions, :extra_bottle_price_min, :price_range_min
    rename_column :warehouse_promotions, :extra_bottle_price_max, :price_range_max

    drop_table :user_promotion_codes
    drop_table :promotion_codes
  end
end
