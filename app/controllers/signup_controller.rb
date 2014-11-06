require 'mailchimp'

class SignupController < ApplicationController
  include UserMailer
  before_action :authenticate_user!, :except => [:create, :mailing_list_signup]

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

    errors = []
    if params[:address_s].blank?
      errors << ['Address can\'t be blank']
    end

    if params[:mobile].blank?
      errors << ['Mobile can\'t be blank']
    end

    if errors.blank?
      current_user.mobile = params[:mobile]
      current_user.save
    else
      render :json => {:errors => errors}, :status => 422
      return
    end

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

    puts mim['mi']

    if mim != 0 && mim['mi'] <= max_current_distance
      we_deliver = true
    else
      if mim != 0 && mim['mi'] <= max_future_distance
        we_will_deliver = true
      end
    end

    puts we_deliver
    puts closed

    puts closed && we_deliver

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

end
