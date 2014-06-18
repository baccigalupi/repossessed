require "bundler/gem_tasks"

require 'rake/testtask'
require 'minitest'

desc "run specs"
task :spec do
  $: << File.dirname(__FILE__)

  require 'lib/repossessed'

  Dir.glob("./spec/support/**/*.rb").each { |f| require f }

  if spec = ARGV[1]
    require spec
  else
    Dir.glob('./spec/**/*_spec.rb').each { |file| require file}
  end
end
