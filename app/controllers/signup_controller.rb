require 'mailchimp'

class SignupController < ApplicationController
  include UserMailer
  before_action :authenticate_user!, :except => [:create, :mailing_list_signup]

  # POST /signup/create
  def create

    if params[:user][:password].blank?
      render :json => {:errors => ['Password is required.']}, :status => 422
      return
    end

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

    if params[:address_id].blank? || params[:address_id] == '0'
      address = Address.create
    else
      address = Address.find(params[:address_id])
    end

    if address.blank?
      errors << 'Editing non existent address'
      render :json => {:errors => current_user.errors}, :status => 422
      return
    end

    errors = []

    if params[:new_address] == 'true' || params[:new_address].blank?

      if params[:address_s].blank?
        errors << 'Address can\'t be blank'
      end

      if errors.blank? && params[:mobile].blank?
        errors << 'Mobile can\'t be blank'
      end

      if errors.blank? && validate_uk_phone(params[:mobile]).blank?
        errors << 'Mobile number is not valid'
      end

      if errors.blank?
        current_user.mobile = validate_uk_phone(params[:mobile])
        unless current_user.save
          render :json => {:errors => current_user.errors}, :status => 422
          return
        end

      else
        render :json => {:errors => errors}, :status => 422
        return
      end

      address.detail = params[:address_d]
      address.street = params[:address_s]
      address.postcode = params[:address_p].upcase

    end

    if address.save
      existing_association = AddressesUsers.find_by(:address => address, :user => current_user)

      if existing_association.blank?
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
        render :json => address.to_json
      end

    else
      render :json => {:errors => address.errors.full_messages}, :status => 422
      logger.error "Couldn't save address"
    end

  end

  def mailing_list_signup

    unless params[:email] =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
      render :json => {:errors => ['Please enter valid email address.']}, :status => 422
      return
    end

    mailing_list = MailingList.find_by(key: params[:list_key])

    distances = params[:distances]

    subscriber_info = {
        :postcode => params[:postcode],
        :distances => distances
    }

    new_subscriber = Subscriber.create!(
        :mailing_list => mailing_list,
        :email => params[:email],
        :info => subscriber_info
    )

    closed = params[:closed]

    mailchimp = Mailchimp::API.new(Rails.application.config.mailchimp_key)

    mim = 0
    unless distances.blank?
      distances_array = JSON.parse(distances)
      mim = distances_array.min_by { |distance| distance['mi'] }
    end

    max_future_distance = 15
    max_current_distance = Rails.application.config.max_delivery_distance
    we_deliver = false
    we_will_deliver = false

    if mim != 0 && mim['mi'] <= max_current_distance
      we_deliver = true
    else
      if mim != 0 && mim['mi'] <= max_future_distance
        we_will_deliver = true
      end
    end

    if closed && we_deliver
      begin
        mailchimp.lists.subscribe('4fe50cdebb',
                                  {
                                      'email' => params[:email],
                                      'postcode' => params[:postcode]
                                  }, nil, 'html', false)
      rescue Mailchimp::ListAlreadySubscribedError
        render :json => {:errors => ['You are already subscribed to the list']}, :status => 422
        return
      rescue => ex
        puts 'Something went wrong'
        puts json: ex
      end
    else

      if we_will_deliver
        coming_soon_near_you(params[:email])
      else
        order_at_your_desk(params[:email])
      end
    end

    render :json => new_subscriber.to_json

  end

  private

  def user_params
    params.require(:user).permit(:first_name, :email, :password)
  end

  def validate_uk_phone(number)

    number = number.strip

    # Strip country code if provided (either +44 or 0044)
    if number.starts_with?('+44')
      number.slice! '+44'
    end

    if number.starts_with?('0044')
      number.slice! '0044'
    end

    number = number.strip

    # Strip leading 0s
    if number.starts_with?('0')
      number.slice! '0'
    end

    # Strip spaces, dashes, parenthesis and full stops
    number = number.delete(' ').delete('-').delete('"').delete('.').delete('\'')
    # number = number.delete('-')

    # What remains must be a 10 digit number or a 9 digit number as long as it doesn't begin with a 7.
    # A leading 7 is a mobile number and must be 10 digits.
    if number.starts_with?('7') && number.length != 10
      return nil
    end

    if !number.starts_with?('7') && number.length != 9
      return nil
    end

    number

  end

end
