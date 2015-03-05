class CreatePromotions < ActiveRecord::Migration
  def up
    create_table :promotions do |t|
      t.string :title
      t.integer :category, default: 0, null: false
      t.datetime :deleted_at, index: true
      t.timestamps
    end

    create_table :referrals do |t|
      t.references :promotion, index: true
      t.references :user, index: true
      t.datetime :deleted_at, index: true
      t.timestamps
    end

    create_table :referral_codes do |t|
      t.references :referral, index: true
      t.string :code
      t.datetime :deleted_at, index: true
      t.timestamps
    end

    create_table :user_promotions do |t|
      t.references :user, index: true
      t.integer :category, null: false
      t.references :referral_code, index: true
      t.references :friend, index: true
      t.boolean :redeemed, default: false, null: false
      t.datetime :deleted_at, index: true
      t.timestamps
    end

    create_table :warehouse_promotions do |t|
      t.references :warehouse, index: true
      t.references :promotion, index: true
      t.boolean :active
      t.numrange :price_range
      t.datetime :deleted_at, index: true
      t.timestamps
    end

    add_reference :order_items, :user_promotions
    add_reference :order_items, :warehouse_promotions

  end

  def down
    remove_reference :order_items, :user_promotions
    remove_reference :order_items, :warehouse_promotions

    drop_table :warehouse_promotions
    drop_table :user_promotions
    drop_table :referral_codes
    drop_table :referrals
    drop_table :promotions
  end

  def db
    ActiveRecord::Base.connection
  end
end
