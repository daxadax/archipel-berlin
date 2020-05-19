require 'rubygems'
require 'bundler/setup'
require 'dotenv'
require 'json'

Dotenv.load
Bundler.require

require './lib/apocalypse_admin.rb'
require './apocalypse_deliveries_app'

require 'securerandom'
set :session_secret, ENV.fetch('SESSION_SECRET') { SecureRandom.hex(64) }

run ApocalypseDeliveriesApp
