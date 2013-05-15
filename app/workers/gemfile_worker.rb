class GemfileWorker
  include Sidekiq::Worker

  def perform
    Repo.process_gemfiles

    sleep 30

    GemfileWorker.perform_async
  end
end
