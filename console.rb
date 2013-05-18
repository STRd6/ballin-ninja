#!/usr/bin/env ruby

require "./config/environments"
require "./models"
require "logger"
require "pry"

ActiveRecord::Base.logger = Logger.new(STDOUT)

DB.connect

pry
