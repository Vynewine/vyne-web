require 'resque/server'

class AuthenticatedMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    if env['warden'].authenticated? && env['warden'].user.admin?
      @app.call(env)
    else
      [403, {'Content-Type' => 'text/plain'}, ['Authenticate first']]
    end
  end
end

Resque::Server.use(AuthenticatedMiddleware)

Resque.redis = Rails.application.config.redis