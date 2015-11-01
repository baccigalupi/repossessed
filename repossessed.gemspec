# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'repossessed/version'

Gem::Specification.new do |spec|
  spec.name          = "repossessed"
  spec.version       = Repossessed::VERSION
  spec.authors       = ["Kane Baccigalupi"]
  spec.email         = ["baccigalupi@gmail.com"]
  spec.description   = %q{Single Responsibility for your ActiveRecord convenience}
  spec.summary       = %q{Single Responsibility for your ActiveRecord convenience: ActiveRecord does everything for you at the cost of breaking single responsibility.
That isn't such a bad thing at first. But eventually callbacks and validations grow out of control with complex use cases for the data. Repossessed breaks many ActiveRecord
concepts into separate classes moving responsibility into custom builders instead of the persistence class.}
  spec.homepage      = "http://github.com/baccigalupi/repossessed"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "activerecord"
  spec.add_development_dependency "sqlite3"
end
