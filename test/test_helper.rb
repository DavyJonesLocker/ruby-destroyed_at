require 'bundler/setup'
require 'destroyed_at'
require 'minitest/autorun'
require 'active_record'
require 'byebug'
require 'timecop'

class Minitest::Spec
  class << self
    alias :context :describe
  end
end

ActiveRecord::Base.establish_connection(
  :adapter => defined?(JRUBY_VERSION) ? 'jdbcsqlite3' : 'sqlite3',
  :database => ':memory:'
)

ActiveRecord::Base.connection.execute(%{CREATE TABLE users (id INTEGER PRIMARY KEY, destroyed_at DATETIME, type STRING);})

class User < ActiveRecord::Base
  include DestroyedAt
end

class Person < User
  before_destroy :set_before_flag
  after_destroy  :set_after_flag

  attr_accessor :before_flag, :after_flag

  def set_before_flag
    self.before_flag = true
  end

  def set_after_flag
    self.after_flag = true
  end
end
