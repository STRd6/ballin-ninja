class TreeWorker
  include Sidekiq::Worker

  def perform
    Repo.process_trees
  end
end
