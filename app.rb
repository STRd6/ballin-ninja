#!/usr/bin/env ruby

require "newrelic_rpm"
require "sinatra"

require_relative "config/environments"
require_relative "app/models/api_token"

Dir[File.dirname(__FILE__) + '/app/workers/*.rb'].each do |file|
  require file
end

DB.connect

set :haml, :format => :html5

set :protection, :except => [:http_origin]

post "/jobs/:name" do |name|
  "#{name}Worker".constantize.perform_async
end

get "/tokens/deactivate" do
  haml :deactivate
end

post "/tokens/deactivate" do
  if record = ApiToken.find_by_token(params[:token])
    record.update_attributes(:active => false)
    "OK!"
  else
    status 406
    "NOT OK!"
  end
end

get "/tokens" do
  haml :tokens
end

post "/tokens" do
  token = params[:token]
  record = ApiToken.create :token => token

  if record.valid?
    "OK!"
  else
    status 406
    "NOT OK!"
  end
end

__END__

@@ layout
!!!
%body
  = yield

@@ tokens
%form(action='/tokens' method='post')
  %input(name='token')

@@ deactivate
%form(action='/tokens/deactivate' method='post')
  %input(name='token')
