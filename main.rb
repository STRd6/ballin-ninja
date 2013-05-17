require 'active_support/core_ext'

require "newrelic_rpm"

require "./config/environments"
require "./models"

Dir[File.dirname(__FILE__) + '/app/workers/*.rb'].each do |file|
  require file
end

DB.connect

# Get the ball rolling
HeartbeatWorker.perform_async
GemfileWorker.perform_async
TreeWorker.perform_async
UpdateWorker.perform_async
