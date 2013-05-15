require 'net/http'

class HeartbeatWorker
  include Sidekiq::Worker

  def perform
    # Clear out arrythmia
    Sidekiq.redis do |redis|
      jobs = redis.zrange "schedule", 0, 1
      # TODO: Heartbeat may not be the only scheduled job in the future
      jobs.each do |job|
        redis.zrem "schedule", job
      end
    end

    # Set the next heartbeat
    HeartbeatWorker.perform_in 2.minutes

    Net::HTTP.get("pure-scrubland-1990.herokuapp.com", "/workers")
  end
end
