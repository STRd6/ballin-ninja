require_relative "base_worker"

class UpdateWorker < BaseWorker
  def delay
    2.minutes
  end

  def perform
    highlander do
      ActiveRecord::Base.uncached do
        Repo.process_updates
      end
    end
  end
end
