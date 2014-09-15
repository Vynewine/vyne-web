class HomeController < ApplicationController

  def index
    # require 'pp'
    # puts PP.pp(request['HTTP_X_MSISDN'],'',80)
  end

  def code
    puts "User code: " + current_user.code
    # require 'pp'
    # puts PP.pp(current_user,'',80)
    # @confirmationCode = rand(9999).to_s.rjust(4, "0")
    # generate 4-digit code
    # persist
    # send sms
  end

  def activate
    @user = User.find_by(:id => current_user.id)
    if @user.code == params['code']['confirmation']
      @user.add_role(:client)
      @user.active = true
      if @user.save
        redirect_to welcome_path
      end
    else
      redirect_to entercode_path
    end
  end

  def warehouses
    @warehouses = Warehouse.all
  end

end
