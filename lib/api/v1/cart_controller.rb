class API::V1::CartController < ApplicationController

  def index
    render :json => {status: :success}
  end

  def create

    cart = Cart.new

    set_cart(cart)

    if cart.save
      cookies[:cart_id] = {
          :value => cart.id,
          :expires => cart.expire_on
      }

      @cart = cart

      render :show

    else
      render :json => {
                 status: :failure,
                 errors: cart.errors.full_messages
             }
    end
  end

  def update

    cart = Cart.find(params[:id])

    if cart.blank?
      cart = Cart.new
    end

    set_cart(cart)

    if cart.save
      cookies[:cart_id] = {
          :value => cart.id,
          :expires => cart.expire_on
      }

      @cart = cart

      render :show

    else
      render :json => {
                 status: :failure,
                 errors: cart.errors.full_messages
             }
    end

  end

  def show
    @cart = Cart.find(params[:id])
  end

  def create_item

    @cart_item = CartItem.new({
                                 cart_id: params[:cart_id]
                             })

    unless params[:category_id].blank?
      @cart_item.category_id = params[:category_id]
    end

    if @cart_item.save
      @cart = @cart_item.cart
      render :show_item
    else
      render :json => {
                 status: :failure,
                 errors: @cart_item.errors.full_messages
             }
    end
  end

  def update_item

    if params[:item_id].blank?
      render :json => {
                 status: :failure,
                 errors: ['Cart item id required']
             }, status: :unprocessable_entity

      return
    end

    @cart_item = CartItem.find(params[:item_id])

    unless params[:category_id].blank?
      @cart_item.category_id = params[:category_id]
    end

    if @cart_item.save
      @cart = @cart_item.cart
      render :show_item
    else
      render :json => {
                 status: :failure,
                 errors: @cart_item.errors.full_messages
             }
    end

  end

  private

  def set_cart(cart)

    cart.expire_on = 2.days.from_now

    unless params[:postcode].blank?
      cart.postcode = params[:postcode]
    end

    if user_signed_in?
      cart.client = current_user.id
    else
      cart.client = 'anonymous'
    end

    unless params[:delivery_type].blank?

      cart.delivery_type = Cart.delivery_types[params[:delivery_type]]
      cart.delivery_expires_on = 1.hour.from_now

      unless params[:slot_date].blank? || params[:slot_from].blank? || params[:slot_to].blank?

        delivery_slot_from = ActiveSupport::TimeZone['Europe/London'].parse(params[:slot_date] + ' ' + params[:slot_from]).utc
        delivery_slot_to = ActiveSupport::TimeZone['Europe/London'].parse(params[:slot_date] + ' ' + params[:slot_to]).utc

        cart.delivery_schedule = {
            slot_date: params[:slot_date],
            slot_from: delivery_slot_from.strftime('%H:%M'),
            slot_to: delivery_slot_to.strftime('%H:%M')
        }
      end
    end
  end
end