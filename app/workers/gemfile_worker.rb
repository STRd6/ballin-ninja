require_relative "base_worker"

class GemfileWorker < BaseWorker
  def perform
    highlander do
      ActiveRecord::Base.uncached do
        Repo.process_gemfiles
      end
    end
  end
end
