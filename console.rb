#!/usr/bin/env ruby

require "./config/environments"
require "./models"
require "./app/models/api_token"
require "logger"
require "pry"

ActiveRecord::Base.logger = Logger.new(STDOUT)

DB.connect

pry
