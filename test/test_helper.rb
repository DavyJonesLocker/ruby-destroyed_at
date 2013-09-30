require 'bundler/setup'
require 'destroyed_at'
require 'minitest/autorun'
require 'active_record'
require 'byebug'
require 'timecop'
require 'database_cleaner'

class Minitest::Spec
  class << self
    alias :context :describe
  end

  before do
    DatabaseCleaner.start
  end

  after do
    DatabaseCleaner.clean
  end
end

ActiveRecord::Base.establish_connection(
  :adapter => defined?(JRUBY_VERSION) ? 'jdbcsqlite3' : 'sqlite3',
  :database => ':memory:'
)

DatabaseCleaner.strategy = :truncation

ActiveRecord::Base.connection.execute(%{CREATE TABLE users (id INTEGER PRIMARY KEY, destroyed_at DATETIME, type STRING);})
ActiveRecord::Base.connection.execute(%{CREATE TABLE profiles (id INTEGER PRIMARY KEY, destroyed_at DATETIME, user_id INTEGER);})
ActiveRecord::Base.connection.execute(%{CREATE TABLE cars (id INTEGER PRIMARY KEY, user_id INTEGER);})
ActiveRecord::Base.connection.execute(%{CREATE TABLE dinners (id INTEGER PRIMARY KEY, destroyed_at DATETIME, user_id INTEGER);})
ActiveRecord::Base.connection.execute(%{CREATE TABLE shows (id INTEGER PRIMARY KEY, destroyed_at DATETIME, user_id INTEGER);})
ActiveRecord::Base.connection.execute(%{CREATE TABLE fleets (id INTEGER PRIMARY KEY, destroyed_at DATETIME, user_id INTEGER, car_id INTEGER);})

class User < ActiveRecord::Base
  include DestroyedAt
  has_one :profile, :dependent => :destroy
  has_one :car, :dependent => :destroy
  has_many :dinners, :dependent => :destroy
  has_one :show
  has_many :fleets
  has_many :cars, :through => :fleets, :dependent => :destroy
  before_save :increment_counter

  attr_accessor :before_save_count, :nil_attribute

  private

  def increment_counter
    @counter ||= 0
    @counter = @counter + 1
  end
end

class Person < User
  before_destroy :set_before_flag
  after_destroy  :set_after_flag

  before_restore :set_before_flag
  after_restore  :set_after_flag

  attr_accessor :before_flag, :after_flag

  def set_before_flag
    self.before_flag = true
  end

  def set_after_flag
    self.after_flag = true
  end
end

class Profile < ActiveRecord::Base
  include DestroyedAt
  belongs_to :user
end

class Car < ActiveRecord::Base
  belongs_to :user
  has_many :fleets
end

class Dinner < ActiveRecord::Base
  include DestroyedAt
  belongs_to :user
end

class Show < ActiveRecord::Base
  include DestroyedAt
end

class Fleet < ActiveRecord::Base
  include DestroyedAt
  belongs_to :user
  belongs_to :car
end
