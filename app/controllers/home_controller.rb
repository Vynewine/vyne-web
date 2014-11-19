class HomeController < ApplicationController

  def index
    if user_signed_in?
      redirect_to neworder_path
    end
  end

  def code
    puts "User code: " + current_user.code
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

end
