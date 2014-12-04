require 'mailchimp'

class HomeController < ApplicationController
  before_action :check_the_gate, :except => [:mailing_list_signup]

  def index

    unless params['device'].blank?
      cookies[:device] = { :value => params['device'], :expires => 3.years.from_now }
    end

    if !cookies[:device].blank? && !user_signed_in?
      redirect_to login_path, alert: 'Please contact Vyne to setup this device'
    end

    if user_signed_in?

      if user_can_access_device
        if @device.registration_id.blank?
          render 'device_registration'
          return
        else
          redirect_to admin_orders_path
          return
        end
      end

      if cookies[:device]
        sign_out current_user
        redirect_to login_path, alert: 'Please contact Vyne to setup this device'
        return
      else
        redirect_to neworder_path
      end
    end
  end

  def code
    puts 'User code: ' + current_user.code
  end

  def activate
    @user = User.find_by(:id => current_user.id)
    if @user.code == params['code']['confirmation']
      @user.add_role(:client)
      @user.active = true
      orders = current_user.orders.where(:status_id => 1)
      orders.each do |order|
        order.status_id = 2
        order.save
      end
      if @user.save
        redirect_to welcome_path
      end
    else
      redirect_to entercode_path
    end
  end

  def warehouses
    @warehouses = Warehouse.where(:active => true)
  end

  def terms
  end

  def mailing_list_signup

    unless params[:email] =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
      render :json => {:errors => ['Please enter valid email address.']}, :status => 422
      return
    end

    mailchimp = Mailchimp::API.new(Rails.application.config.mailchimp_key)

    begin
      mailchimp.lists.subscribe('995ed98f5f', {:email => params[:email]}, nil, 'html', false)
    rescue Mailchimp::ListAlreadySubscribedError
      render :json => {:errors => ['You are already subscribed to the list']}, :status => 422
      return
    rescue => exception
      message = "Error while signing up user to mailing list on home page. #{exception.class} - #{exception.message}"
      logger.error message
      logger.error exception.backtrace
      render :json => {:errors => [message]}, :status => 500
      return
    end

    render :json => {:success => true}
  end

  private

  def user_can_access_device

    if cookies[:device].blank?
      return false
    end

    unless current_user.has_role? :supplier
      return false
    end

    @device = Device.find_by_key(cookies[:device])

    if @device.blank? || @device.warehouses.blank? || current_user.warehouses.blank?
      return false
    end

    (@device.warehouses & current_user.warehouses).each do
      return true
    end

    false
  end

end
