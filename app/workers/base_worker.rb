class BaseWorker
  include Sidekiq::Worker

  def delay
    15
  end

  def queue
    Sidekiq::Queue.new self.class.get_sidekiq_options["queue"]
  end

  # There can be only one
  def highlander
    slay = -> job { job.delete if job.klass == self.class.name }

    # Clear queue of others copies of this job
    queue.each(&slay)
    Sidekiq::RetrySet.new.each(&slay)
    Sidekiq::ScheduledSet.new.each(&slay)

    yield

    # Enque the future generations
    self.class.perform_in delay
  end
end
