class SignupController < ApplicationController
  # skip_before_filter :verify_authenticity_token, :only => [:create, :address]

  # POST /signup/create
  def create

    # Creates user:
    new_user = User.create!(user_params)

    # Signs user in:
    sign_in(:user, new_user)

    respond_to do |format|
      format.html { render json: new_user }
      format.json { render json: new_user }
    end
  end

  # POST /signup/address
  def address
    address = Address.new
    address.detail   = params[:address_d]
    address.street   = params[:address_s]
    address.postcode = params[:address_p].gsub(/[\s|-]/, "").upcase
    if address.save
      address_association = AddressesUsers.new
      address_association.user = current_user
      address_association.address = address
      unless address_association.save
        logger.error "Couldn't save address association"
      end
    else
      logger.error "Couldn't save address"
    end

    respond_to do |format|
      format.html { render json: address }
      format.json { render json: address }
    end

  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :mobile, :password, :password_confirmation)
  end

end
