class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :configure_permitted_parameters, if: :devise_controller?

  layout 'aidani'

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u|
      u.permit(:email, :password, :password_confirmation, :first_name, :last_name, :mobile)
    }
  end

  #Used to check for invitation code
  def check_the_gate

    if user_signed_in?
      return
    end

    unless params['device'].blank?
      cookies[:device] = {:value => params['device'], :expires => 3.years.from_now}
    end

    unless Rails.application.config.enable_invite_code == 'false'
      if cookies[:invite_code] == Rails.application.config.invite_code || params[:monitoring] == 'true'
        return
      end

      if params[:invite_code].blank?
        redirect_to gate_path
        return
      end

      unless params[:invite_code].blank?
        if params[:invite_code].strip.downcase == Rails.application.config.invite_code
          cookies[:invite_code] = {:value => Rails.application.config.invite_code, :expires => 3.months.from_now}
          return
        else
          redirect_to gate_path
          return
        end
      end
    end
  end

end
