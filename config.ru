require "sidekiq"
require 'sidekiq/web'

Dir[File.dirname(__FILE__) + '/app/workers/*.rb'].each do |file|
  require file
end

# Sidekiq::Web.use Rack::Auth::Basic do |username, password|
#   username == 'duder2' && password == ENV['SIDEKIQ_PASS']
# end

run Sidekiq::Web
