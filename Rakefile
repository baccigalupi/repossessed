require "bundler/gem_tasks"

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)


namespace :db do
  desc "Create dbs: no-op because sqlite"
  task :create do
    # no-op
  end

  desc "Run migrations"
  task :migrate do
    require 'yaml'
    require 'active_record'

    configuration = YAML.load(File.read(File.expand_path("../spec/db/database.yml", __FILE__)))
    env = ENV['RAILS_ENV'] || ENV['RACK_ENV'] || 'test'
    ActiveRecord::Base.establish_connection(configuration[env])

    ActiveRecord::Migrator.migrate(File.expand_path('../spec/db/migrations', __FILE__))
  end
end
