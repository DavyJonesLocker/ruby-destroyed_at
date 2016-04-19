require 'test_helper'

describe 'destroying an activerecord instance' do
  let(:post) { Post.create }

  it 'sets the timestamp it was destroyed at' do
    time = Time.now
    Timecop.freeze(time) do
      post = Post.create
      post.destroy
      post.destroyed_at.must_equal time
    end
  end

  it 'does not delete the record' do
    post.destroy
    Post.all.must_be_empty
    Post.unscoped.load.wont_be_empty
  end

  it 'sets #destroyed?' do
    post.destroy
    post.destroyed?.must_equal true
    post = Post.unscoped.last
    post.destroyed?.must_equal true
    post.restore
    post.destroyed?.must_equal false
  end

  it 'runs destroy callbacks' do
    post.destroy_callback_count.must_equal nil
    post.destroy
    post.destroy_callback_count.must_equal 1
  end

  it 'does not run update callbacks' do
    post.destroy
    post.update_callback_count.must_equal nil
    post.restore
    post.update_callback_count.must_equal nil
  end

  it 'decrements the counter cache' do
    author = Author.create
    post = author.posts.create

    author.reload.posts_count.must_equal 1
    post.destroy
    author.reload.posts_count.must_equal 0
  end

  it 'stays persisted after destruction' do
    post.destroy
    post.persisted?.must_equal true
  end

  it 'destroys dependent relation with DestroyedAt' do
    post.comments.create
    Post.count.must_equal 1
    Comment.count.must_equal 1
    post.destroy
    Post.count.must_equal 0
    Comment.count.must_equal 0
  end

  it 'destroys dependent through relation with DestroyedAt' do
    commenter = Commenter.create
    Comment.create(:post => post, :commenter => commenter)

    Commenter.count.must_equal 1
    Comment.count.must_equal 1
    post.destroy
    Commenter.count.must_equal 1
    Comment.count.must_equal 0
  end

  it 'deletes dependent relations without DestroyedAt' do
    category = Category.create
    Categorization.create(:category => category, :post => post)
    post.categorizations.count.must_equal 1
    post.destroy
    Categorization.unscoped.count.must_equal 0
  end

  it 'destroys child when parent does not mixin DestroyedAt' do
    avatar = Avatar.create
    author = Author.create(avatar: avatar)
    author.destroy!

    Author.count.must_equal 0
    Avatar.count.must_equal 0
  end

  it 'destroys child with the correct datetime through an an autosaving association' do
    datetime = 10.minutes.ago

    commenter = Commenter.create

    comment = commenter.comments.build
    commenter.save

    comment.mark_for_destruction(datetime)
    commenter.save

    comment.destroyed_at.must_equal datetime
  end

end

describe 'restoring an activerecord instance' do
  let(:author) { Author.create }
  let(:timestamp) { DateTime.current }
  let(:post) { Post.create(:destroyed_at => timestamp) }

  it 'restores the record' do
    Post.all.must_be_empty
    post.reload
    post.restore
    post.destroyed_at.must_be_nil
    Post.all.wont_be_empty
  end

  it 'runs the restore callbacks' do
    post.restore_callback_count.must_equal nil
    post.restore
    post.restore_callback_count.must_equal 1
  end

  it 'does not run restore validations' do
    initial_count = post.validation_count
    post.restore
    initial_count.must_equal post.validation_count
  end

  it 'restores polymorphic has_many relation with DestroyedAt' do
    comment = Comment.create
    Like.create(likeable: comment)
    comment.destroy

    Comment.count.must_equal 0
    Like.count.must_equal 0

    comment.reload
    comment.restore
    Comment.count.must_equal 1
    Like.count.must_equal 1
  end

  it 'restores polymorphic has_one relation with DestroyedAt' do
    post = Post.create
    Like.create(likeable: post)
    post.destroy

    Post.count.must_equal 0
    Like.count.must_equal 0

    post.reload
    post.restore
    Post.count.must_equal 1
    Like.count.must_equal 1
  end

  it 'restores a dependent has_many relation with DestroyedAt' do
    Comment.create(:destroyed_at => timestamp, :post => post)
    Comment.count.must_equal 0
    post.reload
    post.restore
    Comment.count.must_equal 1
  end

  it 'does not restore a non-dependent relation with DestroyedAt' do
    Post.count.must_equal 0
    Author.count.must_equal 0
    post.reload
    post.restore
    Post.count.must_equal 1
    Author.count.must_equal 0
  end

  it 'restores a dependent through relation with DestroyedAt' do
    commenter = Commenter.create
    Comment.create(:post => post, :commenter => commenter, :destroyed_at => timestamp)

    Commenter.count.must_equal 1
    Comment.count.must_equal 0
    post.reload
    post.restore
    Commenter.count.must_equal 1
    Comment.count.must_equal 1
  end

  it 'restores only the dependent relationships destroyed when the parent was destroyed' do
    post = Post.create
    comment_1 = Comment.create(post: post, destroyed_at: Time.now - 1.day)
    comment_2 = Comment.create(post: post)
    post.destroy
    post.reload # We have to reload the object before restoring in the test
                # because the in memory object has greater precision than
                # the database records
    post.restore
    post.comments.wont_include comment_1
    post.comments.must_include comment_2
  end
end

describe 'deleting a record' do
  it 'is not persisted after deletion' do
    post = Post.create
    post.delete
    post.persisted?.must_equal false
  end

  it 'can delete destroyed records and they are marked as not persisted' do
    post = Post.create
    post.destroy
    post.persisted?.must_equal true
    post.delete
    post.persisted?.must_equal false
  end
end

describe 'destroying an activerecord instance without DestroyedAt' do
  it 'does not impact ActiveRecord::Relation.destroy' do
    post = Post.create
    categorization  = Categorization.create(post: post)
    post.categorizations.destroy(categorization.id)
    post.categorizations.must_be_empty
  end
end

describe 'creating a destroyed record' do
  it 'does not allow new records with destroyed_at columns present to be marked persisted' do
    post = Post.new(destroyed_at: Time.now)
    post.persisted?.must_equal false
  end
end

describe 'non destroyed-at models' do
  it 'can destroy has_one dependants' do
    person = Person.create!
    person.create_pet!

    person.destroy

    assert_equal(0, Person.count, 'Person must be zero')
    assert_equal(0, Pet.count, 'Pet must be zero')
  end

  it 'can destroy has_many dependants' do
    author = Author.create!
    author.posts.create!

    author.destroy

    assert_equal(0, Author.count, 'Author must be zero')
    assert_equal(0, Post.count, 'Post must be zero')
  end
end

describe 'destroying a child that destroys its parent on destroy' do
  it 'destroys the parent record' do
    parent = Person.create!
    child = DestructiveChild.create!(person: parent)

    child.destroy

    assert_equal(0, Person.count, 'Person must be one')
    assert_equal(0, DestructiveChild.count, 'DestructiveChild must be zero')
  end
end

