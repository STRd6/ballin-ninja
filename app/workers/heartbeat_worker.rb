require 'net/http'

class HeartbeatWorker < BaseWorker
  def delay
    2.minutes
  end

  def perform
    highlander do
      # TODO: Move ping target to env
      Net::HTTP.get("pure-scrubland-1990.herokuapp.com", "/workers")
    end
  end
end
