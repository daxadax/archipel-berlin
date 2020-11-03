require 'dotenv'
Dotenv.load

require 'sequel'
DATABASE_CONNECTION = Sequel.connect(ENV['DATABASE_URL'])
Sequel::Model.plugin :timestamps, update_on_create: true
Sequel::Model.plugin :update_or_create

require './lib/archipel_berlin.rb'
require './lib/apocalypse.rb'
require './archipel_berlin_app'
