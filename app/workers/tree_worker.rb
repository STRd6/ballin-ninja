require_relative "base_worker"

class TreeWorker < BaseWorker
  def perform
    highlander do
      ActiveRecord::Base.uncached do
        Repo.process_trees
      end
    end
  end
end
