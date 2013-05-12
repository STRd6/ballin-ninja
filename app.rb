#!/usr/bin/env ruby

require "haml"
require "sinatra"
require 'sinatra/activerecord'
require "sinatra/json"
require './config/environments'
require "./models"

set :haml, :format => :html5

get "/repos" do
  @repos = Repo.all

  haml :repos
end

get "/repos/:id" do |id|
  @repo = Repo.includes(:ruby_gems).find(id)

  haml :repo
end

get "/gems" do
  @gems = RubyGem.all

  haml :gems
end

get "/gems/:id" do |id|
  @gem = RubyGem.includes(:repos).find(id)

  haml :gem
end
