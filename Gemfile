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
group :production do
  gem 'rails_12factor'
end

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
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0',          group: :doc

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
gem 'spring',        group: :development

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]


# Login stuff
gem 'devise'
gem 'authority'
gem 'rolify'

# Charging API
gem 'stripe', :git => 'https://github.com/stripe/stripe-ruby'

# Solr and Sunspot
gem 'progress_bar'
gem 'sunspot_rails'
gem 'sunspot_solr' # optional pre-packaged Solr distribution for use in development

# Mandrill API
gem 'mandrill-api'

#Process CSV and XLS files
gem 'roo', '~> 1.13.2'

#Sentry
gem 'sentry-raven', :require => 'raven', :git => 'https://github.com/getsentry/raven-ruby.git'

#Mailchimp
gem 'mailchimp-api'

#Prevent from permanently deleting records
gem 'paranoia', '~> 2.0'

#Add some damn pagination yeah!
gem 'will_paginate', '~> 3.0'

#PostGIS Spatial Capabilities
gem 'activerecord-postgis-adapter'

#Timezon fun
gem 'tzinfo'

#Spatial to JSON
gem 'rgeo-geojson'

#Google GCM
gem 'gcm'

#Let's get some Bootstrap goodness
gem 'bootstrap-sass', '~> 3.3.1'

#More Magic
gem 'autoprefixer-rails'

#Time conversion for UI
gem 'local_time'

#Google API and OAuth
gem 'google-api-client'

#REST Client
gem 'rest-client'

#Resque for running Background Job (Depends on Redis, check README instructions for installing Redis)
gem 'resque', '~> 1.25.2'

#Scheduling Work on Job Queue
gem 'clockwork'

#More Robust Web Server
gem 'unicorn'

