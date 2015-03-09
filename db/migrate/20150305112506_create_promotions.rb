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
      t.boolean :can_be_redeemed, default: false, null: false
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

    execute <<-SQL
      ALTER TABLE referrals
        ADD CONSTRAINT fk_referrals_promotions
        FOREIGN KEY (promotion_id)
        REFERENCES promotions(id)
    SQL

    execute <<-SQL
      ALTER TABLE referral_codes
        ADD CONSTRAINT fk_referral_codes_referrals
        FOREIGN KEY (referral_id)
        REFERENCES referrals(id)
    SQL

    execute <<-SQL
      ALTER TABLE user_promotions
        ADD CONSTRAINT fk_user_promotions_referral_codes
        FOREIGN KEY (referral_code_id)
        REFERENCES referral_codes(id)
    SQL

    execute <<-SQL
      ALTER TABLE warehouse_promotions
        ADD CONSTRAINT fk_warehouse_promotions_warehouses
        FOREIGN KEY (warehouse_id)
        REFERENCES warehouses(id)
    SQL

    execute <<-SQL
      ALTER TABLE warehouse_promotions
        ADD CONSTRAINT fk_warehouse_promotions_promotions
        FOREIGN KEY (promotion_id)
        REFERENCES promotions(id)
    SQL

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
