# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
run Rails.application

Thread.new do
  while true do
    p :memory_counts => ObjectSpace.count_objects
    sleep 60
  end
end
