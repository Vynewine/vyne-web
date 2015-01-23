require 'json'

class SessionsController < Devise::SessionsController
  def create
    params[:user].merge!(remember_me: '1')
    resource = warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#failure")
    sign_in_and_redirect(resource_name, resource)
  end

  def sign_in_and_redirect(resource_or_scope, resource=nil)
    scope = Devise::Mapping.find_scope!(resource_or_scope)
    resource ||= resource_or_scope
    sign_in(scope, resource) unless warden.user(scope) == resource

    if current_user.admin?
      cookies[:warehouses] = 'admin'
    else
      unless current_user.warehouses.blank?
        cookies[:warehouses] = current_user.warehouses.map { |warehouse| warehouse.id }.join(',')
      end
    end

    respond_to do |format|
      format.html { redirect_to home_index_path }
      format.json {
        render :json => {
                   :success => true,
                   :user => current_user,
                   :addresses => current_user.addresses.order(updated_at: :desc),
                   :payments => current_user.payments.order(updated_at: :desc),
                   :csrfToken => form_authenticity_token
               }
      }
    end

  end

  def failure
    respond_to do |format|
      format.html {
        redirect_to new_user_session_path, :flash => {:error => "Invalid email/password combination"}
      }
      format.json {
        render :json => {:success => false, :errors => ["Invalid email/password combination"]}
      }
    end
  end

end