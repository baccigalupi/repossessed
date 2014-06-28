# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'repossessed/version'

Gem::Specification.new do |spec|
  spec.name          = "repossessed"
  spec.version       = Repossessed::VERSION
  spec.authors       = ["Kane Baccigalupi"]
  spec.email         = ["developers@socialchorus.com"]
  spec.description   = %q{Repository, Validator, Parser rebuild to repossess your code from ActiveRecord}
  spec.summary       = %q{Repository, Validator, Parser rebuild to repossess your code from ActiveRecord}
  spec.homepage      = "http://github.com/socialchorus/repossessed"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
