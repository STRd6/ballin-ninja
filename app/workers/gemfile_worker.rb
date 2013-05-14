class GemfileWorker
  include Sidekiq::Worker

  def perform
    Repo.process_gemfiles
  end
end
