class SignupController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:create, :address]

  # POST /signup/create
  def create

    new_user = User.create(user_params)

    if new_user.save
      sign_in(:user, new_user)
      render :json => new_user.to_json
    else
      render :json => {:errors => new_user.errors.full_messages}, :status => 422
      logger.error "Couldn't save new user"
    end

  end

  # POST /signup/address
  def address
    address = Address.create
    address.detail = params[:address_d]
    address.street = params[:address_s]
    address.postcode = params[:address_p].gsub(/[\s|-]/, "").upcase
    if address.save
      address_association = AddressesUsers.new
      address_association.user = current_user
      address_association.address = address
      if address_association.save
        render :json => address.to_json
      else
        render :json => {:errors => address_association.errors.full_messages}, :status => 422
        logger.error "Couldn't save address association"
      end
    else
      render :json => {:errors => address.errors.full_messages}, :status => 422
      logger.error "Couldn't save address"
    end

  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :mobile, :password, :password_confirmation)
  end

end
