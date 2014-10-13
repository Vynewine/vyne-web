require 'json'

class SessionsController < Devise::SessionsController
  def create
    resource = warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#failure")
    sign_in_and_redirect(resource_name, resource)
  end

  def sign_in_and_redirect(resource_or_scope, resource=nil)
    scope = Devise::Mapping.find_scope!(resource_or_scope)
    resource ||= resource_or_scope
    sign_in(scope, resource) unless warden.user(scope) == resource

    respond_to do |format|
      format.html { redirect_to home_index_path }
      format.json {
        render :json => {
            :success => true,
            :addresses => current_user.addresses.order(updated_at: :desc).to_json,
            :payment => current_user.payments.order(updated_at: :desc).to_json
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