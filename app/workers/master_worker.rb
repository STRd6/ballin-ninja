class MasterWorker
  include Sidekiq::Worker

  def perform
    # Clear out all master tasks
    Sidekiq::Queue.new("default").each do |job|
      if job.klass == self.class.name
        job.delete
      end
    end

    # Set the next master worker
    MasterWorker.perform_in 10.minutes

    GemfileWorker.perform_async
    TreeWorker.perform_async

    puts 'King of the castle'
  end
end
