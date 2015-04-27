source 'https://rubygems.org'

ruby '2.1.2'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.1.4'

gem 'pg'

group :test do
  gem 'sqlite3', '1.3.9'
  gem 'stripe-ruby-mock', '~> 1.10.1.7'
  gem 'webmock', '1.19.0'
  gem 'mocha'
  gem 'selenium-webdriver'
end


# Recommended by Heroku
# Takes care of sending logs to STDOUT and Serving Static Assets
gem 'rails_12factor'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.3'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer',  platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks', '~> 2.5.3'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
gem 'spring', group: :development

# Login stuff
gem 'devise'
gem 'authority'
gem 'rolify'

# Charging API
gem 'stripe'

# Solr and Sunspot
gem 'progress_bar'
gem 'sunspot_rails'
gem 'sunspot_solr' # optional pre-packaged Solr distribution for use in development

# Mandrill API
gem 'mandrill-api'

# Process CSV and XLS files
gem 'roo', '~> 1.13.2'

# Sentry
gem 'sentry-raven', :require => 'raven', :git => 'https://github.com/getsentry/raven-ruby.git'

# Mailchimp
gem 'mailchimp-api'

# Prevent from permanently deleting records
gem 'paranoia', '~> 2.0'
gem 'paranoia_uniqueness_validator', '1.1.0'

# Add some damn pagination yeah!
gem 'will_paginate', '~> 3.0'

# PostGIS Spatial Capabilities
gem 'activerecord-postgis-adapter'

# Timezon fun
gem 'tzinfo'

# Spatial to JSON
gem 'rgeo-geojson'

# Google GCM
gem 'gcm'

# Let's get some Bootstrap goodness
gem 'bootstrap-sass', '~> 3.3.1'

# More Magic
gem 'autoprefixer-rails'

# Time conversion for UI
gem 'local_time'
gem 'momentjs-rails' , '~> 2.9.0'

# Google API and OAuth
gem 'google-api-client'

# REST Client
gem 'rest-client', '~> 1.6.8'

# Resque for running Background Job (Depends on Redis, check README instructions for installing Redis)
gem 'resque', '~> 1.25.2'
gem 'resque-scheduler', '~> 4.0.0'

# Scheduling Work on Job Queue
gem 'clockwork'

# More Robust Web Server
gem 'puma'

group :production do
  # Web Monitoring with New Relic
  # gem 'newrelic_rpm'
  # Performance monitoring
  gem 'skylight'
end

# Well obvious
gem 'pgbackups-archive'

# Twilio
gem 'twilio-ruby'

# Web Sockets
gem 'faye-websocket'

# Recommended by Heroku to use with Puma Web Server
gem 'rack-timeout'

# New Landing Page Fonts
gem 'font-awesome-rails'

# React
gem 'react-rails', '~> 0.13.0.0'

gem 'logging-rails', :require => 'logging/rails'

# Segment IO
gem 'analytics-ruby', :require => 'segment/analytics'


# Bower Gems
source 'https://rails-assets.org' do
  gem 'rails-assets-react-router'
  # gem 'rails-assets-flux'
  gem 'rails-assets-marty'
end