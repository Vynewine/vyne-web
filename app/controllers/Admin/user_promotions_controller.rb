class Admin::UserPromotionsController < ApplicationController
  layout 'admin'
  before_action :authenticate_user!
  authorize_actions_for AdminAuthorizer


  def index

  end

  def show
    @user_promotion = UserPromotion.find(params[:id])
  end


end