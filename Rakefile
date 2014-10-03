require "bundler/gem_tasks"

require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = false
end

# Allows us to add tests specific to GitHub issues. These won't get run when `rake` is called,
# so they shouldn't slow down the test suite unless you explicitly want to run them with 
# `rake issues_tests`.
#
Rake::TestTask.new(:issues_tests) do |t|
  t.description = 'Run tests pertaining to open GitHub issues.'
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/issues_tests.rb'
  t.verbose = false
end

task :default => :test
