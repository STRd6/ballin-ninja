require 'net/http'
require_relative "base_worker"

class HeartbeatWorker < BaseWorker
  def delay
    2.minutes
  end

  def perform
    highlander do
      Net::HTTP.get("pure-scrubland-1990.herokuapp.com", "/workers")

      # TODO: Consider resussitating busted processes
    end
  end
end
