class API::V1::CartController < ApplicationController
  def index
    render :json => {status: :success}
  end

  def create
    cart = Cart.new(
        expire_on: 2.days.from_now
    )

    unless params[:postcode].blank?
      cart.postcode = params[:postcode]
    end

    if user_signed_in?
      cart.client = current_user.id
    else
      cart.client = 'anonymous'
    end

    if cart.save
      cookies[:cart_id] = {
          :value => cart.id,
          :expires => cart.expire_on
      }

      render :json => {
                 status: :success,
                 data: {
                     cart: cart
                 }
             }
    else
      render :json => {
                 status: :failure,
                 messages: cart.errors.full_messages
             }
    end
  end

  def update

  end

end