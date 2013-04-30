require 'rubygems'
require 'bundler/setup'
Bundler.require :default

require 'robut'
require 'ostruct'
require 'logger'

load ARGV[0] || './Chatfile'

Robut::App.set :connection, Robut::Connection.new.connect

run Robut::App
