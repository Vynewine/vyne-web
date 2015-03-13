class Admin::ReferralsController < ApplicationController
  layout 'admin'
  before_action :authenticate_user!
  authorize_actions_for AdminAuthorizer
  before_action :set_referral, only: [:show, :edit, :update, :destroy]

  def index
    @referrals = Referral.all.order('id DESC').page(params[:page])
  end

  def show
  end

  def new
    @referral = Referral.new
    @promotions = Promotion.all
  end

  def edit
    @promotions = Promotion.all
  end

  def create
    @referral = Referral.new(referral_params)
    if @referral.save
      redirect_to [:admin, @referral], notice: 'Referral was successfully created.'
    else
      flash[:error] = @referral.errors.full_messages().join(', ')
      @promotions = Promotion.all
      render :new
    end

  end

  def update
    if @referral.update(referral_params)
      redirect_to [:admin, @referral], notice: 'Referral was successfully updated.'
    else
      flash[:error] = @referral.errors.full_messages().join(', ')
      render :edit
    end
  end

  def destroy
    @referral.destroy
    redirect_to admin_referrals_url, notice: 'Referral was successfully destroyed.'
  end

  private

  def set_referral
    @referral = Referral.find(params[:id])
  end

  def referral_params
    params.require(:referral).permit(:promotion_id, :user_id)
  end

end