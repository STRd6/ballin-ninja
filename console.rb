#!/usr/bin/env ruby

require "./config/environments"
require "./models"
require "./app/models/api_token"
require "logger"
require "pry"
require "sidekiq"

Dir[File.dirname(__FILE__) + '/app/workers/*.rb'].each do |file|
  require file
end

ActiveRecord::Base.logger = Logger.new(STDOUT)

DB.connect

pry
