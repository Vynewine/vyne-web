class RegistrationsController < Devise::RegistrationsController
  def new
    super
  end

  def create

    super

    unless cookies[:referral_code].blank?
      errors = PromotionHelper.apply_sign_up_promotion(current_user, cookies[:referral_code])
      #TODO Not sure how to handle error here
      if errors.blank?
        cookies.delete :referral_code
      end
    end

  end

  def update
    super
  end

end