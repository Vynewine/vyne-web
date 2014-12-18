web: bundle exec unicorn -p $PORT -c ./config/unicorn.rb
worker: env QUEUE=* bundle exec rake resque:work
clock: bundle exec clockwork lib/clock.rb