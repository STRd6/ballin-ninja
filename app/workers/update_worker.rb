require_relative "base_worker"

class UpdateWorker < BaseWorker
  def perform
    highlander do
      ActiveRecord::Base.uncached do
        Repo.process_updates
      end
    end
  end
end
