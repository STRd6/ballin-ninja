#!/usr/bin/env ruby

require "sinatra"

Dir[File.dirname(__FILE__) + '/app/workers/*.rb'].each do |file|
  require file
end

set :haml, :format => :html5

set :protection, :except => [:http_origin]

post "/jobs/:name" do |name|
  "#{name}Worker".constantize.perform_async
end
