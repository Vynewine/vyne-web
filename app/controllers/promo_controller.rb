class PromoController < ApplicationController

  def index
    if user_signed_in?
      get_promo_info
    else
      unless params[:promo].blank?
        @code = params[:promo].upcase
      end
    end
  end

  def create

    if user_signed_in?
      get_promo_info
    end

    @code = ''

    unless params[:promo_code].blank?
      @code = params[:promo_code].strip.upcase
    end

    if @code.blank?
      flash.now[:error] = 'Please enter Promo Code.'
      render :index
      return
    end

    promotion_code = PromotionCode.find_by(code: @code, active: true)

    if promotion_code.blank?
      flash.now[:error] = "We can't locate promo code provided. Please make sure it's correct and enter it again."
      render :index
      return
    end

    unless promotion_code.restrictions.blank?
      flash.now[:error] = promotion_code.restrictions.join(' ')
      render :index
      return
    end

    if user_signed_in?

      if promotion_code.promotion.new_accounts_only
        unless current_user.orders.blank?
          flash.now[:error] = 'This promotion is for new customers only.'
          render :index
          return
        end
      end

      errors = PromotionHelper.add_promotion(current_user, promotion_code.code)

      if errors.blank?
        flash[:success] = 'Promotion has been applied to your account.'
        redirect_to promo_index_path
      else
        flash.now[:error] = errors.join(' ')
        render :index
        return
      end



    else

      cookies[:promo_code] = {:value => @code, :expires => 1.month.from_now}

      if params[:postcode].blank?
        flash.now[:error] = 'Please enter Postcode.'
        render :index
        return
      end

      redirect_to availability_index_path({:postcode => params[:postcode]})

    end

  end

  private

  def get_promo_info
    promo_code = nil
    redeemed_promotions = []
    redeemable_promotions = []
    pending_promotions = []
    referrals = []

    unless current_user.promotion_codes.blank?

      promo_codes = current_user.promotion_codes.select { |code| code.active }.sort_by(&:created_at).reverse!

      unless promo_codes.blank?
        promo_code = promo_codes.map { |code| code.code }.first
      end
    end

    unless current_user.user_promotions.blank?
      redeemed_promotions = current_user.user_promotions.select { |promo| promo.redeemed }
      redeemable_promotions = current_user.user_promotions.select { |promo|
        promo.redeemed == false && promo.can_be_redeemed
      }
      pending_promotions = current_user.user_promotions.select { |promo|
        promo.redeemed == false && promo.can_be_redeemed == false
      }
    end

    unless current_user.referrals.blank?
      referrals = current_user.referrals
    end

    @promotion = {
        :promo_code => promo_code,
        :redeemed_promotions => redeemed_promotions,
        :redeemable_promotions => redeemable_promotions,
        :pending_promotions => pending_promotions,
        :referrals => referrals
    }
  end
end