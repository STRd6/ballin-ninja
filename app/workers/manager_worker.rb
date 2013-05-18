class ManagerWorker < BaseWorker
  def stats
    Sidekiq::Stats.new
  end

  def perform
    highlander do
      ActiveRecord::Base.uncached do
        if stats.enqueued < 500
          Repo.select(:id).where(:master_branch => nil).limit(100).each do |repo|
            ModelWorker.perform_async "Repo", repo.id, "ensure_master_branch"
          end
        end
      end
    end
  end
end
