class MasterWorker
  include Sidekiq::Worker

  def perform(name, count)
    puts 'King of the castle'
  end
end
