require 'bundler/setup'
require 'active_record'
require 'destroyed_at'
require 'minitest/autorun'
require 'byebug'
require 'timecop'
require 'database_cleaner'

class MiniTest::Spec
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

ActiveRecord::Base.connection.execute(%{CREATE TABLE authors (id INTEGER PRIMARY KEY, posts_count INTEGER DEFAULT 0);})
ActiveRecord::Base.connection.execute(%{CREATE TABLE avatars (id INTEGER PRIMARY KEY, author_id INTEGER, destroyed_at DATETIME);})
ActiveRecord::Base.connection.execute(%{CREATE TABLE categories (id INTEGER PRIMARY KEY);})
ActiveRecord::Base.connection.execute(%{CREATE TABLE categorizations (id INTEGER PRIMARY KEY, category_id INTEGER, post_id INTEGER);})
ActiveRecord::Base.connection.execute(%{CREATE TABLE comments (id INTEGER PRIMARY KEY, commenter_id INTEGER, post_id INTEGER, destroyed_at DATETIME);})
ActiveRecord::Base.connection.execute(%{CREATE TABLE commenters (id INTEGER PRIMARY KEY, destroyed_at DATETIME);})
ActiveRecord::Base.connection.execute(%{CREATE TABLE destructive_children (id INTEGER PRIMARY KEY, person_id INTEGER, destroyed_at DATETIME);})
ActiveRecord::Base.connection.execute(%{CREATE TABLE images (id INTEGER PRIMARY KEY, post_id INTEGER);})
ActiveRecord::Base.connection.execute(%{CREATE TABLE posts (id INTEGER PRIMARY KEY, author_id INTEGER, destroyed_at DATETIME);})
ActiveRecord::Base.connection.execute(%{CREATE TABLE people (id INTEGER PRIMARY KEY);})
ActiveRecord::Base.connection.execute(%{CREATE TABLE pets (id INTEGER PRIMARY KEY, person_id INTEGER);})
ActiveRecord::Base.connection.execute(%{CREATE TABLE likes (id INTEGER PRIMARY KEY, likeable_id INTEGER, likeable_type TEXT, destroyed_at DATETIME);})

class Author < ActiveRecord::Base
  has_many :posts, dependent: :destroy
  has_one :avatar, dependent: :destroy
end

class Person < ActiveRecord::Base
  has_many :destructive_children
  has_one :pet, dependent: :destroy
end

class Pet < ActiveRecord::Base
  belongs_to :person
end

class Avatar < ActiveRecord::Base
  include DestroyedAt
  belongs_to :author
end

class Category < ActiveRecord::Base
  has_many :categorizations
  has_many :posts, through: :categorizations
end

class Categorization < ActiveRecord::Base
  belongs_to :category
  belongs_to :post
end

class Like < ActiveRecord::Base
  include DestroyedAt
  belongs_to :likeable, polymorphic: true
end

class Comment < ActiveRecord::Base
  include DestroyedAt
  belongs_to :post
  belongs_to :commenter

  has_many :likes, as: :likeable, dependent: :destroy
end

class Commenter < ActiveRecord::Base
  include DestroyedAt
  has_many :comments, dependent: :destroy, autosave: true
  has_many :posts, through: :comments
end

class DestructiveChild < ActiveRecord::Base
  belongs_to :person, dependent: :destroy
end

class Post < ActiveRecord::Base
  include DestroyedAt

  belongs_to :author, counter_cache: true
  has_many :categories, through: :categorizations
  has_many :categorizations, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :commenters, through: :comments
  has_one :like, as: :likeable, dependent: :destroy

  before_destroy :increment_destroy_callback_counter
  before_restore :increment_restore_callback_counter
  before_update :increment_update_callback_counter

  validate :increment_validation_counter

  attr_accessor :destroy_callback_count, :restore_callback_count, :update_callback_count, :validation_count

  private

  def increment_restore_callback_counter
    self.restore_callback_count ||= 0
    self.restore_callback_count = self.restore_callback_count + 1
  end

  def increment_destroy_callback_counter
    self.destroy_callback_count ||= 0
    self.destroy_callback_count = self.destroy_callback_count + 1
  end

  def increment_update_callback_counter
    self.update_callback_count ||= 0
    self.update_callback_count = self.update_callback_count + 1
  end

  def increment_validation_counter
    self.validation_count ||= 0
    self.validation_count = self.validation_count + 1
  end
end
