class GemfileWorker
  include Sidekiq::Worker

  def perform
    ActiveRecord::Base.uncached do
      Repo.process_gemfiles
    end

    sleep 30

    GemfileWorker.perform_async
  end
end
