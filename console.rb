#!/usr/bin/env ruby

require "./app"

ActiveRecord::Base.logger = Logger.new(STDOUT)

binding.pry
