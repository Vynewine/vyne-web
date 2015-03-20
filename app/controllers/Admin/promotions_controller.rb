class Admin::PromotionsController < ApplicationController
  layout 'admin'
  before_action :authenticate_user!
  authorize_actions_for AdminAuthorizer
  before_action :set_promotion, only: [:show, :edit, :update, :destroy]

  def index
    @promotions = Promotion.all.order(:id)
  end

  def show
    @warehouse_promotions = WarehousePromotion.where(:promotion_id => params[:id])
  end

  def new
    @promotion = Promotion.new
    @categories = Category.all
  end

  def edit
    @categories = Category.all
  end

  def create
    @promotion = Promotion.new(promotion_params)
    if @promotion.save
      redirect_to admin_promotion_path(@promotion), notice: 'Promotion was successfully created.'
    else
      flash.now[:error] = @promotion.errors.full_messages.join(', ')
      render :new
    end
  end

  def update
    if @promotion.update(promotion_params)
      redirect_to admin_promotion_path(@promotion), notice: 'Promotion was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @promotion.destroy
    redirect_to admin_promotions_path, notice: 'Promotion was successfully destroyed.'
  end

  private

  def set_promotion
    @promotion = Promotion.find(params[:id])
  end

  def promotion_params
    params.require(:promotion).permit(
        :title,
        :category,
        :active,
        :free_delivery,
        :extra_bottle,
        :free_bottle_category_id,
        :referral_promotion,
        :description,
        :new_accounts_only
    )
  end

end