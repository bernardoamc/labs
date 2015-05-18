ENV['RACK_ENV'] ||= 'development'

require 'bundler'
require 'active_record'
require 'yaml'
Bundler.require :default, ENV['RACK_ENV'].to_sym

databases = YAML.load_file("config/database.yml")
ActiveRecord::Base.establish_connection(databases[ENV["RACK_ENV"] || "development"])

require_relative 'models/user'
