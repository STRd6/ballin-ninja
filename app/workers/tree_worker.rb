require_relative "base_worker"

class TreeWorker < BaseWorker
  def delay
    1.minutes
  end

  def perform
    highlander do
      ActiveRecord::Base.uncached do
        Repo.process_trees
      end
    end
  end
end
