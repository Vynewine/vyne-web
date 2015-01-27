workers Integer(ENV['WEB_CONCURRENCY'] || 2)
threads_count = Integer(ENV['MAX_THREADS'] || 1)
threads threads_count, threads_count

preload_app!

rackup DefaultRackup
port ENV['PORT'] || 5000
environment ENV['RACK_ENV'] || 'development'

on_worker_boot do
  ActiveSupport.on_load(:active_record) do
    config = ActiveRecord::Base.configurations[Rails.env] ||
        Rails.application.config.database_configuration[Rails.env]
    config['adapter'] = 'postgis'
    config['pool'] = ENV['MAX_THREADS'] || 5
    ActiveRecord::Base.establish_connection(config)
  end

  if defined?(Resque)
    Resque.redis = Rails.application.config.redis
  end
end