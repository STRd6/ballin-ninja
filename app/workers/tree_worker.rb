class TreeWorker
  include Sidekiq::Worker

  def perform
    Repo.process_trees

    sleep 60

    TreeWorker.perform_async
  end
end
