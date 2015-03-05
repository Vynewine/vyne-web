class PromoController < ApplicationController

  def create
    # Validate
    # If Valid Save to user's session
    redirect_to :show, notice: 'Promo code was successfully applied to your account.'
    # Else redirect to index with error
    render :index

  end
end