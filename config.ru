require 'rubygems'
require 'bundler/setup'
require 'dotenv'
require 'json'

Dotenv.load
Bundler.require

print "##############################\n\n"
print "Using DATABASE:  #{ENV['DATABASE_URL']}\n\n"
print "##############################\n"

require 'sequel'
DATABASE_CONNECTION = Sequel.connect(ENV['DATABASE_URL'])
Sequel::Model.plugin :timestamps, update_on_create: true
Sequel::Model.plugin :update_or_create

require './lib/archipel_berlin.rb'
require './lib/apocalypse.rb'

require 'securerandom'
set :session_secret, ENV.fetch('SESSION_SECRET') { SecureRandom.hex(64) }

require './app/controllers/base.rb'
Dir.glob('./app/controllers/*.rb') { |f| require f }

# Access Sinatra Middleware's functionality
# Allows us to use PATCH PUT DELETE requests
use Rack::MethodOverride

# Mount additional controllers
use AdminController
use UsersController
use OrganizationsController
use DeliveryRequestsController

run BaseController
