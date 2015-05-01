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

      render :json => {
                 status: :success,
                 data: cart
             }
    else
      render :json => {
                 status: :failure,
                 messages: cart.errors.full_messages
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

      render :json => {
                 status: :success,
                 data: cart
             }
    else
      render :json => {
                 status: :failure,
                 messages: cart.errors.full_messages
             }
    end

  end

  def show
    cart = Cart.find(params[:id])

    render :json => {
               status: :success,
               data: cart
           }
  end

  def create_item
    cart_item = CartItem.new({
                                 cart_id: params[:id]
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