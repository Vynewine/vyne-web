task 'resque:setup' => :environment do

  ENV['QUEUE'] = '*' if ENV['QUEUE'].blank?

  # Resque.before_fork = Proc.new {
  #   config = ActiveRecord::Base.configurations[Rails.env] ||
  #       Rails.application.config.database_configuration[Rails.env]
  #   config['adapter'] = 'postgis'
  #   ActiveRecord::Base.establish_connection(config)
  # }

  Resque.after_fork do |worker|
    config = ActiveRecord::Base.configurations[Rails.env] ||
        Rails.application.config.database_configuration[Rails.env]
    config['adapter'] = 'postgis'
    ActiveRecord::Base.establish_connection(config)
  end

end