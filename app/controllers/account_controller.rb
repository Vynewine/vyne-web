class AccountController < ApplicationController
  layout 'aidani'

  before_action :authenticate_user!
  authorize_actions_for UserAuthorizer

  def index
    @promo_codes = []
    @redeemed_promotions = []
    @redeemable_promotions = []
    @pending_promotions = []

    unless current_user.referrals.blank?
      active_referrals = current_user.referrals.select{|referral| referral.promotion.active}.sort_by &:created_at

      latest_referral = active_referrals.first

      active_codes = latest_referral.referral_codes.select{|code| code.active}.sort_by &:created_at

      unless active_codes.blank?
        @promo_codes = active_codes.map{|code| code.code}
      end
    end

    unless current_user.user_promotions.blank?
      @redeemed_promotions = current_user.user_promotions.select{|promo| promo.redeemed }
      @redeemable_promotions = current_user.user_promotions.select{ |promo|
        promo.redeemed == false && promo.can_be_redeemed
      }
      @pending_promotions = current_user.user_promotions.select{|promo|
        promo.redeemed == false && promo.can_be_redeemed == false
      }
    end
  end
end