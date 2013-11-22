require 'test_helper'

describe 'Scopes' do
  let(:post)     { Post.create! }
  let(:comment_1)  { post.comments.create! }
  let(:comment_2)  { post.comments.create! }
  let(:comment_3)  { Comment.create! }
  let(:comment_4)  { Comment.create! }

  before do
    comment_1
    comment_2.destroy
    comment_3
    comment_4.destroy
  end

  describe '.destroyed' do
    context 'Called on model' do
      let(:destroyed_comments) { Comment.destroyed }

      it 'returns records that have been destroyed' do
        destroyed_comments.must_include comment_2
        destroyed_comments.must_include comment_4
      end

      it 'does not return current records' do
        destroyed_comments.wont_include comment_1
        destroyed_comments.wont_include comment_3
      end
    end

    context 'Called on relation' do
      let(:destroyed_comments) { post.comments.destroyed }

      it 'returns destroyed records beloning in the relation' do
        destroyed_comments.must_include comment_2
      end

      it 'does not return destroyed records that are outside the relation' do
        destroyed_comments.wont_include comment_4
      end

      it 'does not return current records in the relation' do
        destroyed_comments.wont_include comment_1
      end

      it 'does not return current records that are outside the relation' do
        destroyed_comments.wont_include comment_3
      end
    end
  end
end
