Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Enable Rack::Cache to put a simple HTTP cache in front of your application
  # Add `rack-cache` to your Gemfile before enabling this.
  # For large-scale production use, consider using a caching reverse proxy like nginx, varnish or squid.
  # config.action_dispatch.rack_cache = true

  # Disable Rails's static asset server (Apache or nginx will already do this).
  config.serve_static_assets = false

  # Compress JavaScripts and CSS.
  config.assets.js_compressor = :uglifier
  # config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Generate digests for assets URLs.
  config.assets.digest = true

  # `config.assets.precompile` has moved to config/initializers/assets.rb

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # Devise mailer:
  config.action_mailer.default_url_options = { host: 'www.vyne.co.uk', scheme: 'https' }
  # In production, :host should be set to the actual host of your application.

  # Prepend all log lines with the following tags.
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups.
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.action_controller.asset_host = "http://assets.example.com"

  # Precompile additional assets.
  # application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
  # config.assets.precompile += %w( search.js )

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Disable automatic flushing of the log to improve performance.
  # config.autoflush_log = false

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Mandrill API
  config.mandrill = 'ipcLBLgQRHya2q3jvpPQsw'

  # Stripe
  config.stripe_key = ENV['STRIPE_KEY']

  config.stripe_key_publishable = ENV['STRIPE_KEY_PUBLISHABLE']

  # Shutl
  config.shutl_url = ENV['SHUTL_URL']

  config.shutl_id = ENV['SHUTL_ID']
  # "UOuPfVIAvP4BJWDmXdCiSw==" ??

  config.shutl_secret = ENV['SHUTL_SECRET']
  # "DAiXY/UzTM14g6PAqAHDrm/ILwkJ3fT5mnh7aT15JiPI6YLz5GYN7qLtx4Yac60PFN+rZRuZuFyi0FExri3F6w==" ??

  # Segment IO
  config.segment_io_write_key =  '0zwU3t4m36'

  # Sentry
  config.sentry_dns = 'https://d8178d04a5164db7be5668971be436a3:1bc7da2220874227af68c54d011880ac@app.getsentry.com/32494'

  # Mailchimp
  config.mailchimp_key = '218800eead6b63a85a54db6df3eaedc4-us8'

  # Currrent Delivery Distance (Miles)
  config.max_delivery_distance = ENV['MAX_DELIVERY_DISTANCE'].to_f

  # Vyne order internal notification email
  config.order_notification = ENV['ORDER_NOTIFICATION']

  # Require invitation code to access the site.
  config.enable_invite_code = ENV['ENABLE_INVITE_CODE']
  config.invite_code = ENV['INVITE_CODE']

  # Googe GCM
  config.google_gcm_public_api_key = 'AIzaSyCUuUzZOMAKS1n6kA396bI8FBUWpvdwyWk'

  # Google Coordinate Team Id
  config.google_coordinate_team_id = 'ZtCbuYnbGi9fTxkJtV390w'

  config.google_coordinate_client_id = ENV['CLIENT_ID']
  config.google_coordinate_client_secret = ENV['CLIENT_SECRET']

  # Redis
  config.redis = ENV['OPENREDIS_URL']

  # Twilio
  config.twilio_account_sid = ENV['TWILIO_ACCOUNT_SID']
  config.twilio_auth_token = ENV['TWILIO_AUTH_TOKEN']
  config.twilio_number = ENV['TWILIO_NUMBER']

  # Google Maps API
  config.google_maps_api_link = 'https://maps.google.com/maps/api/js?v=3&sensor=false&key=AIzaSyD1woZtsHcnxYsO3iwD7P6MwYPKgt3FYSw'

end
