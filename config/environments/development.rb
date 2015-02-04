Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Devise mailer:
  config.action_mailer.default_url_options = { host: 'localhost', port: 5000, scheme: 'http' }
  # In production, :host should be set to the actual host of your application.

  config.log_level = :info

  # Mandrill API
  config.mandrill = 'ipcLBLgQRHya2q3jvpPQsw'

  config.assets.prefix = "/dev-assets"

  # Stripe
  config.stripe_key = 'sk_test_AtBOn3YHMmRXJgn0TT9x98Y2'

  config.stripe_key_publishable = 'pk_test_2uUf7eQJy5mj038BJFUtxJfF'

  # Shutl
  config.shutl_url = 'https://sandbox-v2.shutl.co.uk'

  config.shutl_id = 'HnnFB2UbMlBXdD9h4UzKVQ=='

  config.shutl_secret = 'pKNKPPCejzviiPunGNhnJ95G1JdeAbOYbyAygqIXyfIe4lb73iIDKRqmeZmZWT+ORxTqwMP9PhscJAW7GFmz6A=='

  # Segment IO
  config.segment_io_write_key =  'gTrenJGlvC'

  # Sentry
  config.sentry_dns = 'https://8830d38a3ab24cea90a374858941d1f6:70306e5411ca4acea11091a14208176b@app.getsentry.com/32522'

  # Mailchimp
  config.mailchimp_key = '218800eead6b63a85a54db6df3eaedc4-us8'

  # Currrent Delivery Distance (Miles)
  config.max_delivery_distance = 3

  # Vyne order internal notification email
  config.order_notification = 'jakub-order-notification-for-vyne@vyne.london'

  # Require invitation code to access the site.
  config.enable_invite_code = 'false'
  config.invite_code = 'timeforvyne'

  # Googe GCM
  config.google_gcm_public_api_key = 'AIzaSyCUuUzZOMAKS1n6kA396bI8FBUWpvdwyWk'

  # Google Coordinate Team Id
  config.google_coordinate_team_id = 'ZtCbuYnbGi9fTxkJtV390w'
  config.google_coordinate_client_id = '662241065743-4jg7eectv71j6a4na8o327kid6m37tvd.apps.googleusercontent.com'
  config.google_coordinate_client_secret = '5kdwemy_dpS1adj3TFNvAkX2'

  # Redis
  config.redis = 'redis://127.0.0.1:6379/0'

  # Twilio
  config.twilio_account_sid = 'AC1dac7ea5c33e1e694785e5f1d2dbe1c1'
  config.twilio_auth_token = 'f7a10f8654a601e49485efc152faefcf'
  config.twilio_number = '+15005550006'

end
