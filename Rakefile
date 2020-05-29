require 'rake/testtask'

require 'dotenv'
Dotenv.load

task :default => :test

Rake::TestTask.new do |t|
  t.libs << "spec"
  t.test_files = FileList['spec/**/*_spec.rb']
  t.verbose = true
end

namespace :app do
  require './lib/apocalypse_admin.rb'

  desc "Regenerate reports for all existing orders"
  task :regenerate_all_reports do
    ApocalypseAdmin::Models::ShopifyOrder.all.each do |order|
      order.generate_reports
    end
  end
end

namespace :db do
  desc "Drop database for environment in DB_ENV for DB_USER"
  task :drop do
    # DATABASE_CONNECTION.disconnect if DATABASE_CONNECTION

    unless ENV.member?('DB_ENV')
      raise 'Please provide the environment to create for as `ENV[DB_ENV]`'
    end

    env = ENV['DB_ENV']
    user = ENV['DB_USER']

    `dropdb -U #{user} apocalypse-deliveries-#{env}`
    print "Database apocalypse-deliveries-#{env} dropped successfully\n"
  end

  desc "Create database for environment in DB_ENV for DB_USER"
  task :create do
    # DATABASE_CONNECTION.disconnect if DATABASE_CONNECTION

    unless ENV.member?('DB_ENV')
      raise 'Please provide the environment to create for as `ENV[DB_ENV]`'
    end

    env = ENV['DB_ENV']
    user = ENV['DB_USER']

    `createdb -p 5432 -U #{user} apocalypse-deliveries-#{env}`
    print "Database apocalypse-deliveries-#{env} created successfully\n"
  end

  desc "Run migrations (optionally include version number)"
  task :migrate do
    require "sequel"
    Sequel.extension :migration

    # NOTE: example format:
    # DATABASE_URL=postgres://{user}:{password}@{hostname}:{port}/{database-name}
    unless ENV.member?('DATABASE_URL')
      raise 'Please provide a database as `ENV[DATABASE_URL]`'
    end

    version = ENV['VERSION']
    database_url = ENV['DATABASE_URL']
    migration_dir = File.expand_path('../migrations', __FILE__)
    db = Sequel.connect(database_url)

    if version
      puts "Migrating to version #{version}"
      Sequel::Migrator.run(db, migration_dir, :target => version.to_i)
    else
      puts "Migrating"
      Sequel::Migrator.run(db, migration_dir)
    end

    puts 'Migration complete'
  end

  desc "Drop, create and migrate DB"
  task :reset do
    Rake::Task["db:drop"].invoke
    Rake::Task["db:create"].invoke
    Rake::Task["db:migrate"].invoke
  end
end
