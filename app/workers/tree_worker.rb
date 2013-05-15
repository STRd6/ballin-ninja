class TreeWorker
  include Sidekiq::Worker

  def perform
    ActiveRecord::Base.uncached do
      Repo.process_trees
    end

    sleep 60

    TreeWorker.perform_async
  end
end
