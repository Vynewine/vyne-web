task 'resque:setup' => :environment do

  ENV['QUEUE'] = '*' if ENV['QUEUE'].blank?

  # Resque.before_fork = Proc.new {
  #   config = ActiveRecord::Base.configurations[Rails.env] ||
  #       Rails.application.config.database_configuration[Rails.env]
  #   config['adapter'] = 'postgis'
  #   ActiveRecord::Base.establish_connection(config)
  # }

  Resque.before_fork do
    ActiveRecord::Base.connection.disconnect! unless Resque.inline?
  end

  Resque.after_fork do |worker|
    config = ActiveRecord::Base.configurations[Rails.env] ||
        Rails.application.config.database_configuration[Rails.env]
    config['adapter'] = 'postgis'
    ActiveRecord::Base.establish_connection(config)
  end

end

desc 'Alias for resque:work'
task 'jobs:work' => 'resque:work'