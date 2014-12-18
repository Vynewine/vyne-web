task 'resque:setup' => :environment do

  ENV['QUEUE'] = '*' if ENV['QUEUE'].blank?

  Resque.after_fork do |worker|
    config = ActiveRecord::Base.configurations[Rails.env] ||
        Rails.application.config.database_configuration[Rails.env]
    config['adapter'] = 'postgis'
    ActiveRecord::Base.establish_connection(config)
  end

end

desc 'Alias for resque:work'
task 'jobs:work' => 'resque:work'