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

  it 'stays persisted after destruction' do
    post.destroy
    post.persisted?.must_equal true
  end

  it 'destroys dependent relations with DestroyedAt' do
    post.comments.create
    Post.count.must_equal 1
    Comment.count.must_equal 1
    post.destroy
    Post.count.must_equal 0
    Comment.count.must_equal 0
  end

  it 'deletes dependent relations without DestroyedAt' do
    category = Category.create
    Categorization.create(:category => category, :post => post)
    post.categorizations.count.must_equal 1
    post.destroy
    Categorization.unscoped.count.must_equal 0
  end
end

describe 'restoring an activerecord instance' do
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

  it 'restores a has_many relationship with DestroyedAt' do
    Comment.create(:destroyed_at => timestamp, :post => post)
    Comment.count.must_equal 0
    post.reload
    post.restore
    Comment.count.must_equal 1
  end

  it 'restores a has_many through relationship with DestroyedAt' do
    Category.create(:destroyed_at => timestamp, :post => post)
    Comment.count.must_equal 0
    post.reload
    post.restore
    Comment.count.must_equal 1
  end
end

# describe 'destroying and restoring an activerecord instance' do

  # it 'restores has_many through relationship with DestroyedAt' do
    # timestamp = DateTime.current
    # post = Post.create(:destroyed_at => timestamp) # has_many cars through fleets
    # car = Car.create # does not include #destroyed_at
    # fleet = Fleet.create(:destroyed_at => timestamp, :car => car) # includes DestroyedAt
    # post.fleets = [fleet]
    # post.cars.count.must_equal 0
    # post.reload
    # post.restore
    # post.cars.count.must_equal 1
  # end

  # it 'restores only the has_many dependent relationships destroyed when the parent was destroyed' do
    # post = Post.create
    # dinner_one = Comment.create(post: post, destroyed_at: Time.now - 1.day)
    # dinner_two = Comment.create(post: post)
    # post.destroy
    # post.reload # We have to reload the object before restoring in the test
                # # because the in memory object has greater precision than
                # # the database records
    # post.restore
    # post.comments.wont_include dinner_one
    # post.comments.must_include dinner_two
  # end

  # it 'restores only the has_one dependent relationships destroyed when the parent was destroyed' do
    # post = Post.create
    # profile_1 = Profile.create(post: post, destroyed_at: Time.now - 1.day)
    # profile_2 = Profile.create(post: post)
    # post.destroy
    # post.restore
    # post.profile.must_equal profile_2
    # profile_1.reload
    # profile_1.destroyed_at.wont_equal nil
  # end

  # it 'destroys and restores dependent relationships in a belongs_to relationship' do
    # post = Post.create
    # show = Show.create(post: post)
    # show.destroy
    # show.reload
    # post.reload
    # post.destroyed_at.wont_equal nil # post is dependent on show
    # show.restore
    # post.reload
    # post.destroyed_at.must_equal nil
  # end
# end

# describe 'deleting a record' do
  # it 'is not persisted after deletion' do
    # post = Post.create
    # post.delete
    # post.persisted?.must_equal false
  # end

  # it 'can delete destroyed records and they are marked as not persisted' do
    # post = Post.create
    # post.destroy
    # post.persisted?.must_equal true
    # post.delete
    # post.persisted?.must_equal false
  # end
# end

# describe 'destroying an activerecord instance without DestroyedAt' do
  # it 'does not impact ActiveRecord::Relation.destroy' do
    # post = Post.create
    # pet  = Pet.create(post: post)
    # post.pets.destroy(pet.id)
    # post.pets.must_be_empty
  # end
# end

describe 'creating a destroyed record' do
  it 'does not allow new records with destroyed_at columns present to be marked persisted' do
    post = Post.new(destroyed_at: Time.now)
    post.persisted?.must_equal false
  end
end
