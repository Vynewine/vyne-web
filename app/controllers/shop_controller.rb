class ShopController < ApplicationController
  include UserMailer
  before_action :authenticate_user!, :except => [:new, :create]
  authorize_actions_for UserAuthorizer, :except => [:new, :create] # Triggers user check
  before_action :set_order, only: [:show, :edit, :update, :destroy]

  # GET /welcome
  def welcome
  end

  # GET /orders
  # GET /orders.json
  def index
    @orders = Order.all
  end

  # GET /orders/list
  def list
    @orders = Order.find_by(:user => current_user)
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
  end

  # GET /shop/neworder
  def new
    puts params[:controller]
    # current_user.has_role?(:superadmin)
    @order = Order.new
    @categories = Category.all
    @foods = Food.all
    logger.warn "New order"
  end

  # GET /orders/confirmed
  def confirmed
  end

  # GET /orders/1/edit
  def edit
  end

  # POST /orders
  # POST /orders.json
  def create
    require 'pp'
    logger.warn "Create order"
    puts PP.pp(params,'',80)

# {
#   "utf8"=>"✓",
#   "authenticity_token"=>"0lu9BsfjPv6SMYEXlBrkOJoFu0uSe4UXElIFjcC460s=",
#   "preferences"=>{"occasion"=>"", "food"=>"", "type"=>"", "other"=>""},
#   "user"=>
#   {
#     "name"=>"queen elizabeth",
#     "email"=>"queen@gov.uk",
#     "mobile"=>"01234567890",
#     "password"=>"qwertyui",
#     "password_confirmation"=>"qwertyui"
#   },
#   "address_p"=>"w69hh",
#   "address_s"=>"Fulham Palace Road",
#   "address_d"=>"116",
#   "old_address"=>"",
#   "old_card"=>"0",
#   "new_card"=>"4242",
#   "new_brand"=>"1",
#   "stripeToken"=>"tok_14dfAQ2eZvKYlo2CuBYwwobZ",
#   "action"=>"create",
#   "controller"=>"shop"
# }

    # Creates user:
    newUser = User.create!(user_params)

    # Signs user in:
    sign_in(:user, newUser)

    # Creates order:
    @order = Order.new
    @order.client = current_user

    # Manages address:
    orderAddress = params[:old_address].to_i
    if orderAddress == 0
      address = Address.new
      address.detail   = params[:address_d]
      address.street   = params[:address_s]
      address.postcode = params[:address_p].gsub(/[\s|-]/, "").upcase
      if address.save
        addressAssociation = AddressesUsers.new
        addressAssociation.user = current_user
        addressAssociation.address = address
        unless addressAssociation.save
          logger.error "Couldn't save address association"
        end
      else
        logger.error "Couldn't save address"
      end
    else
      address = Address.find(orderAddress)
    end

    @order.address = address

    # Manages card details:

    cardId = params[:old_card].to_i
    puts PP.pp(cardId,'',80)
    if cardId == 0 # New card
      # Set your secret key: remember to change this to your live secret key in production
      # See your keys here https://dashboard.stripe.com/account
      Stripe.api_key = "sk_test_BQokikJOvBiI2HlWgH4olfQ2"

      # Get the credit card details submitted by the form
      token = params[:stripeToken]

      # Create a Customer
      customer = Stripe::Customer.create(
        :card => token,
        :description => current_user.email
      )
      payment        = Payment.new
      payment.user   = current_user
      payment.brand  = params[:new_brand]
      payment.number = params[:new_card]
      payment.stripe = customer.id
      unless addressAssociation.save
        logger.error "Couldn't save payment"
      end
    else
      payment = Payment.find_by(:id => cardId, :user => current_user)
    end

    @order.payment = payment
    @order.status_id = 1
    
    # redirect_to action: 'new'

    respond_to do |format|
      if @order.save
        first_time_ordered newUser
        format.html { redirect_to entercode_path } #, notice: 'Order was successfully created.' }
        format.json { render :confirmed, status: :created, location: @order }
      else
        format.html { render :new }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /orders/1
  # PATCH/PUT /orders/1.json
  def update
    respond_to do |format|
      if @order.update(order_params)
        format.html { redirect_to @order, notice: 'Order was successfully updated.' }
        format.json { render :show, status: :ok, location: @order }
      else
        format.html { render :edit }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /orders/1
  # DELETE /orders/1.json
  def destroy
    @order.destroy
    respond_to do |format|
      format.html { redirect_to orders_url, notice: 'Order was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:name, :email, :mobile, :password, :password_confirmation)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.require(:order).permit(
        # :address_id,
        :warehouse_id,
        :client_id,
        :advisor_id,
        :wine_id,
        :quantity,
        address_attributes: [:id, :detail, :street, :postcode],
      )
    end
end

