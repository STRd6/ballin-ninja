require_relative "base_worker"

class UpdateWorker < BaseWorker
  def perform
    highlander do
      ActiveRecord::Base.uncached do
        puts "lulwat"
      end
    end
  end
end
