# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'destroyed_at/version'

Gem::Specification.new do |spec|
  spec.name          = "destroyed_at"
  spec.version       = DestroyedAt::VERSION
  spec.authors       = ["Michael Dupuis Jr."]
  spec.email         = ["michael.dupuis@dockyard.com"]
  spec.description   = %q{Safe destroy for ActiveRecord.}
  spec.summary       = %q{Safe destroy for ActiveRecord.}
  spec.homepage      = "https://github.com/dockyard/ruby-destroyed_at"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '~> 2.0'

  spec.add_runtime_dependency "activerecord", '~> 4.1'
  spec.add_runtime_dependency 'actionpack', '~> 4.1'

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "appraisal"
  spec.add_development_dependency "minitest", "~> 5.1"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "byebug"
  spec.add_development_dependency "timecop"
  spec.add_development_dependency "database_cleaner", '1.0.1'
end
