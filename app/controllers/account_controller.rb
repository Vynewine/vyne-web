class AccountController < ApplicationController
  layout 'aidani'

  before_action :authenticate_user!
  authorize_actions_for UserAuthorizer

  def index

  end
end