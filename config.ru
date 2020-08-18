require 'rubygems'
require 'bundler/setup'
require 'dotenv'
require 'json'

Dotenv.load
Bundler.require

require './lib/archipel_berlin.rb'
require './archipel_berlin_app'

require 'securerandom'
set :session_secret, ENV.fetch('SESSION_SECRET') { SecureRandom.hex(64) }

run ArchipelBerlinApp
