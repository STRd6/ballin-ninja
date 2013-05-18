require 'active_support/core_ext'

class ModelWorker
  include Sidekiq::Worker

  sidekiq_options :retry => 2, :backtrace => 5

  def perform(klass, id, method, *args)
    ActiveRecord::Base.uncached do
      klass.constantize.find(id).send method, *args
    end
  end
end
