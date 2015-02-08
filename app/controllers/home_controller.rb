require 'mailchimp'

class HomeController < ApplicationController
  before_action :check_the_gate, :except => [:mailing_list_signup, :warehouses, :gate, :aidani]

  layout 'aidani', :only => [ :index ]

  def index

    unless params['device'].blank?
      cookies[:device] = {:value => params['device'], :expires => 3.years.from_now}
    end

    if !cookies[:device].blank? && !user_signed_in?
      redirect_to login_path, alert: 'Please contact Vyne to setup this device'
      return
    end

    if user_signed_in?

      if user_can_access_device
        render 'device_registration'
        return
      end

      if cookies[:device]
        sign_out current_user
        redirect_to login_path, alert: 'Please contact Vyne to setup this device'
        return
      end
    end

    @areas = Warehouse.delivery_areas

    render 'aidani'

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

    if params[:lat].blank? || params[:lng].blank?
      render :json => {}
      return
    end

    warehouses = {warehouses: [], next_opening: {}}
    @warehouses = Warehouse.closest_to(params[:lat], params[:lng])

    unless @warehouses.blank?
      @warehouses.each do |warehouse|
        warehouses[:warehouses] << {
            id: warehouse.id,
            address: warehouse.address.postcode,
            is_open: warehouse.is_open,
            opening_time: warehouse.today_opening_time,
            closing_time: warehouse.today_closing_time,
            opens_today: warehouse.opens_today
        }

      end

      warehouses[:next_opening] = next_open_warehouse(@warehouses)
    end
    render :json => warehouses
  end



  def terms
  end

  def aidani

    @areas = Warehouse.delivery_areas

    render layout: 'aidani'
  end

  def gate

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
    rescue Exception => exception
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

    if @device.blank? || @device.warehouse.blank? || current_user.warehouses.blank?
      return false
    end

    if current_user.warehouses.include?(@device.warehouse)
      return true
    end

    false
  end

  def next_open_warehouse(warehouses)

    today = local_time.wday
    if today == 6 # Saturday
      next_day = 0 # Sunday
    else
      next_day = today + 1
    end

    7.times do

      next_warehouse = warehouses.select{ |w| w.next_open_day == next_day}.first
      unless next_warehouse.blank?
        return {
            :day => next_warehouse.next_open_day,
            :week_day => Date::DAYNAMES[next_warehouse.next_open_day],
            :opening_time => next_warehouse.next_open_day_opening_time,
            :closing_time => next_warehouse.next_open_day_closing_time
        }
      end

      next_day += 1
      if next_day == 6
        next_day = 0
      end
    end
  end

  # Not DRY, Repeated from Warehouse.rb - should move to helper library
  def local_time
    #TODO: In the future we'll make time zone identifier configurable
    time_zone_identifier = 'Europe/London'
    tz = TZInfo::Timezone.get(time_zone_identifier)
    # current local time
    tz.utc_to_local(Time.now.getutc)
  end

end
