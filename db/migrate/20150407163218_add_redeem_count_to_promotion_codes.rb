class AddRedeemCountToPromotionCodes < ActiveRecord::Migration
  def change
    add_column :promotion_codes, :redeem_count, :integer, :default => 0
  end
end
