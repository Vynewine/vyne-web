class Admin::WarehousePromotionsController < ApplicationController
  layout 'admin'
  before_action :authenticate_user!
  authorize_actions_for AdminAuthorizer
  before_action :set_promotion, only: [:new, :edit]

  def new
    @warehouse_promotion = WarehousePromotion.new
    @warehouses = Warehouse.all
  end

  def edit
    @warehouse_promotion = WarehousePromotion.find(params[:id])
    @warehouses = Warehouse.all
  end

  def create

    @warehouse_promotion = WarehousePromotion.new(warehouse_promotion_params)

    @warehouse_promotion.promotion_id = params[:promotion_id]

    if @warehouse_promotion.save
      redirect_to admin_promotion_path(params[:promotion_id]), notice: 'Warehouse promotion successfully created.'
    else
      flash[:error] = @warehouse_promotion.errors.full_messages.join(', ')
      redirect_to admin_promotion_path(params[:promotion_id])
    end
  end

  def update
    @warehouse_promotion = WarehousePromotion.find(params[:id])
    if @warehouse_promotion.update(warehouse_promotion_params)
      redirect_to admin_promotion_path(params[:promotion_id]), notice: 'Warehouse promotion was successfully updated.'
    else
      flash[:error] = @warehouse_promotion.errors.full_messages.join(', ')
      redirect_to admin_promotion_path(params[:promotion_id])
    end
  end

  def destroy
    @warehouse_promotion = WarehousePromotion.find(params[:id])
    @warehouse_promotion.destroy
    redirect_to admin_promotion_path(params[:promotion_id]), notice: 'Warehouse promotion was successfully removed.'
  end

  private

  def set_promotion
    @promotion = Promotion.find(params[:promotion_id])
  end

  def warehouse_promotion_params
    params.require(:warehouse_promotion).permit(:warehouse_id, :active, :extra_bottle_price_min, :extra_bottle_price_max)
  end
end