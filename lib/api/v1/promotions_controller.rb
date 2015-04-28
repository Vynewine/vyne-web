class API::V1::PromotionsController < ApplicationController

  def index

    render :json => {
               status: :success,
               data: get_promotion_info
           }
  end

  private

  def get_promotion_info

    promotion = nil
    promotion_code = ''

    if user_signed_in?

      user_promotion = UserPromotion.order(created_at: :asc).find_by(
          :user => current_user,
          :can_be_redeemed => true,
          :redeemed => false
      )

      unless user_promotion.blank?
        promotion = user_promotion.promotion_code.promotion
        promotion_code = user_promotion.promotion_code.code
      end

    else
      unless cookies[:promo_code].blank?
        promo_code = PromotionCode.find_by(code: cookies[:promo_code], active: true)
        unless promo_code.blank?
          promotion = promo_code.promotion
          promotion_code = promo_code.code
        end
      end
    end

    if promotion.blank?
      {
          :title => '',
          :code => ''
      }
    else

      {
          :title => promotion.title,
          :code => promotion_code
      }
    end
  end

end