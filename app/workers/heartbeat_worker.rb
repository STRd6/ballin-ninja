require 'net/http'

class HeartbeatWorker
  include Sidekiq::Worker

  def perform
    # Clear out arrythmia
    Sidekiq::Queue.new("default").each do |job|
      if job.klass == self.class.name
        job.delete
      end
    end

    # Set the next heartbeat
    HeartbeatWorker.perform_in 2.minutes

    Net::HTTP.get("pure-scrubland-1990.herokuapp.com", "/workers")
  end
end
