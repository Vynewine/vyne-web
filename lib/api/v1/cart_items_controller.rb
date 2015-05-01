class API::V1::CartItemsController < ApplicationController

  def create
    cart_item = CartItem.new({
                                 cart_id: params[:cart_id]
                             })

    unless params[:category_id].blank?
      cart_item.category_id = params[:category_id]
    end

    if cart_item.save
      render :json => {
                 status: :success,
                 data: cart_item
             }
    else
      render :json => {
                 status: :failure,
                 messages: cart_item.errors.full_messages
             }
    end
  end

  def update

  end

end