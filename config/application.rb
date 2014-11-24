require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# This whole shabang to use postgis
class ActiveRecordOverrideRailtie < Rails::Railtie
  initializer 'active_record.initialize_database.override' do |app|

    ActiveSupport.on_load(:active_record) do
      if url = ENV['DATABASE_URL']
        ActiveRecord::Base.connection_pool.disconnect!
        parsed_url = URI.parse(url)
        config = {
            adapter: 'postgis',
            host: parsed_url.host,
            encoding: 'unicode',
            database: parsed_url.path.split("/")[-1],
            port: parsed_url.port,
            username: parsed_url.user,
            password: parsed_url.password
        }
        establish_connection(config)
      end
    end
  end
end

# Regular app initialization here
module Vyne
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.serve_static_assets = true

    Dir.glob("#{Rails.root}/app/assets/images/**/").each do |path|
      config.assets.paths << path
    end

    config.autoload_paths << Rails.root.join('lib')

    # add custom validators path
    config.autoload_paths += %W["#{config.root}/app/validators/"]

    initializer 'setup_asset_pipeline', :group => :all do |app|
      # We don't want the default of everything that isn't js or css, because it pulls too many things in
      app.config.assets.precompile.shift

      # Explicitly register the extensions we are interested in compiling
      app.config.assets.precompile.push(Proc.new do |path|
                                          File.extname(path).in? %w(.html .erb .haml .png .gif .jpg .jpeg .eot .otf .svc .woff .ttf)
                                        end)
    end
  end
end