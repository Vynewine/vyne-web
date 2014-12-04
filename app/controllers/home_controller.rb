require 'mailchimp'

class HomeController < ApplicationController
  before_action :check_the_gate, :except => [:mailing_list_signup]

  def index
    if user_signed_in?
      redirect_to neworder_path
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

end
