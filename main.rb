require 'active_support/core_ext'

require "./config/environments"
require "./models"

Dir[File.dirname(__FILE__) + '/app/workers/*.rb'].each do |file|
  require file
end

DB.connect

# Get the ball rolling
HeartbeatWorker.perform_async

# require "pry"
# binding.pry
