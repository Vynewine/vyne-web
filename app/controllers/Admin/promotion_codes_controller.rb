class Admin::PromotionCodesController < ApplicationController
  layout 'admin'
  before_action :authenticate_user!
  authorize_actions_for AdminAuthorizer
  before_action :set_promotion, only: [:index, :new, :edit, :create, :update]

  def index
    @vyne_codes = PromotionCode.where(promotion: @promotion, category: PromotionCode.categories[:vyne_code])
    @referral_codes = PromotionCode.where(
        promotion_id: params[:promotion_id],
        category: PromotionCode.categories[:referral_code]
    ).page(params[:page]).order(:id)
  end

  def show
    @promotion_code = PromotionCode.find(params[:id])
  end

  def new
    @promotion_code = PromotionCode.new
  end

  def edit
    @promotion_code = PromotionCode.find(params[:id])
  end

  def create
    @promotion_code = PromotionCode.new(promotion_code_params)
    @promotion_code.promotion = @promotion
    if @promotion_code.save
      redirect_to admin_promotion_promotion_codes_path(@promotion_code.promotion), notice: 'Promo Code was successfully created.'
    else
      flash.now[:error] = @promotion_code.errors.full_messages.join(', ')
      render :new
    end
  end

  def update
    @promotion_code = PromotionCode.find(params[:id])
    if @promotion_code.update(promotion_code_params)
      redirect_to admin_promotion_promotion_codes_path(@promotion_code.promotion), notice: 'Promotion code was successfully updated.'
    else
      flash.now[:error] = @promotion_code.errors.full_messages.join(', ')
      render :edit
    end
  end

  def destroy
    @promotion_code = PromotionCode.find(params[:id])
    @promotion_code.destroy
    redirect_to admin_promotion_promotion_codes_path(params[:promotion_id]), notice: 'Promotion Code was successfully removed.'
  end

  def promotion_code_params
    params.require(:promotion_code).permit(:code,
                                           :active,
                                           :expiration_date,
                                           :redeem_count_limit,
                                           :category,
                                           :user_id,
                                           :redeem_count)
  end

  private

  def set_promotion
    @promotion = Promotion.find(params[:promotion_id])
  end
end
