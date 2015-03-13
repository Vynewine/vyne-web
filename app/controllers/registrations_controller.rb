class RegistrationsController < Devise::RegistrationsController
  def new
    super
  end

  def create

    super

    unless current_user.blank?
      if cookies[:referral_code].blank?
        errors = PromotionHelper.enable_referral_promotion(current_user)
        unless errors.blank?
          logger.error errors
        end
      else
        errors = PromotionHelper.apply_sign_up_promotion(current_user, cookies[:referral_code])
        if errors.blank?
          cookies.delete :referral_code
        else
          logger.error errors
        end
      end
    end

  end

  def update
    super
  end

end