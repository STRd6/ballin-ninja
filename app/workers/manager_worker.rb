require_relative "base_worker"

class ManagerWorker < BaseWorker
  def stats
    Sidekiq::Stats.new
  end

  def perform
    highlander do
      ActiveRecord::Base.uncached do
        if stats.enqueued < 500
          Repo.select(:id).where(:state => nil).limit(1000).each do |repo|
            ModelWorker.perform_async "Repo", repo.id, "update_state"
          end
          # Repo.select(:id).where(:master_branch => nil, :error => nil).limit(1000).each do |repo|
          #   ModelWorker.perform_async "Repo", repo.id, "ensure_master_branch"
          # end

          # Repo.where("data IS NULL").select(:id).limit(1000).each do |repo|
          #   ModelWorker.perform_async "Repo", repo.id, "refresh_tree"
          # end
        end
      end
    end
  end
end
