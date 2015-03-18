class Admin::UserPromotionsController < ApplicationController
  layout 'admin'
  before_action :authenticate_user!
  authorize_actions_for AdminAuthorizer


  def index

  end

  def show
    @user_promotion = UserPromotion.find(params[:id])
  end

  def edit
    @user_promotion = UserPromotion.find(params[:id])
  end

  def new
    @user_promotion = UserPromotion.new
    unless params[:user_id].blank?
      user = User.find(params[:user_id])
      @user_promotion.user = user
    end
  end

  def create

    promo_code = nil

    promo_code_param = params[:user_promotion][:promotion_code_id]

    unless promo_code_param.blank?
      if promo_code_param.is_a? Numeric
        promo_code = PromotionCode.find(promo_code_param)
      else
        promo_code = PromotionCode.find_by(code: promo_code_param)
      end
    end

    @user_promotion = UserPromotion.new(user_promotion_params)
    @user_promotion.promotion_code = promo_code

    if @user_promotion.save
      redirect_to admin_user_promotion_path(@user_promotion), notice: 'User Promotion was successfully created.'
    else
      flash.now[:error] = @user_promotion.errors.full_messages.join(', ')
      render :new
    end
  end

  def update
    @user_promotion = UserPromotion.find(params[:id])

    if @user_promotion.update(user_promotion_params)
      redirect_to admin_user_promotion_path(@user_promotion), notice: 'User Promotion was successfully updated.'
    else
      flash.now[:error] = @user_promotion.errors.full_messages.join(', ')
      render :edit
    end
  end

  private

  def user_promotion_params
    params.require(:user_promotion).permit(
        :user_id,
        :redeemed,
        :can_be_redeemed,
        :referral_id
    )
  end

end