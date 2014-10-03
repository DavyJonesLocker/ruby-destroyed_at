# Tests pertaining to opened issues.

# These tests will not run when `rake` is called;
# They must be called explicitly `rake issue_tests`.

require 'test_helper'

describe 'https://github.com/dockyard/destroyed_at/issues/46' do
  module Issue46
    class UserQuestion < ActiveRecord::Base
      has_one :video_file, dependent: :destroy
    end

    class VideoFile < ActiveRecord::Base
      include DestroyedAt
      belongs_to :user_question
    end
  end

  ActiveRecord::Base.connection.execute(%{CREATE TABLE user_questions (id INTEGER PRIMARY KEY);})
  ActiveRecord::Base.connection.execute(%{CREATE TABLE video_files (id INTEGER PRIMARY KEY,
                                                                    destroyed_at DATETIME,
                                                                    user_question_id INTEGER);})

  it 'does not throw undefined_method when destroy! is called on a parent instance' do
    user_question = Issue46::UserQuestion.create
    Issue46::VideoFile.create(user_question: user_question)

    result = Issue46::UserQuestion.last.destroy!
    result.must_equal true
  end
end
