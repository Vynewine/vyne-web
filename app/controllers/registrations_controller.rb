class RegistrationsController < Devise::RegistrationsController
  def new
    super
  end

  def create

    super

    unless current_user.blank?

      errors = PromotionHelper.enable_referral_promotion(current_user)

      unless errors.blank?
        logger.error errors
      end

      unless cookies[:promo_code].blank?
        errors = PromotionHelper.add_promotion(current_user, cookies[:promo_code])
        if errors.blank?
          cookies.delete :promo_code
        else
          logger.error errors
        end
      end

      Resque.enqueue(UserEmailNotification, current_user.id, :account_registration)
    end

  end

  def update
    super
  end

end