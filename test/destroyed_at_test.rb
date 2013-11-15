require 'test_helper'

describe 'destroying an activerecord instance' do
  it 'does not delete the record' do
    user = User.create
    user.destroy
    User.all.must_be_empty
    User.unscoped.load.wont_be_empty
  end

  it 'sets the timestamp it was destroyed at' do
    time = Time.now
    Timecop.freeze(time) do
      user = User.create
      user.destroy
      user.destroyed_at.must_equal time
    end
  end

  it 'sets #destroyed?' do
    user = User.create
    user.destroy
    user.destroyed?.must_equal true
    user = User.unscoped.last
    user.destroyed?.must_equal true
    user.restore
    user.destroyed?.must_equal false
  end

  it 'runs destroy callbacks' do
    person = Person.create
    person.before_flag.wont_equal true
    person.after_flag.wont_equal true
    person.destroy
    person.before_flag.must_equal true
    person.after_flag.must_equal true
  end

  it 'does not run update callbacks' do
    user = User.create
    user.destroy
    user.before_update_count.must_equal nil
    user.restore
    user.before_update_count.must_equal nil
  end

  it 'stays persisted after destruction' do
    user = User.create
    user.destroy
    user.persisted?.must_equal true
  end

  it 'does not allow new records with destroyed_at columns present to be marked persisted' do
    user = User.new(destroyed_at: Time.now)
    user.persisted?.must_equal false
  end

  it 'destroys dependent relations with DestroyedAt' do
    user = User.create
    user.dinners.create
    User.count.must_equal 1
    Dinner.count.must_equal 1
    user.destroy
    User.count.must_equal 0
    Dinner.count.must_equal 0
  end

  it 'does not delete dependent relations with DestroyedAt' do
    user = User.create(:profile => Profile.new)
    user.reload
    user.profile.wont_be_nil
    user.destroy
    Profile.count.must_equal 0
    Profile.unscoped.count.must_equal 1 # includes DestroyedAt
  end

  it 'deletes dependent relations without DestroyedAt' do
    user = User.create(:car => Car.new)
    user.reload
    user.car.wont_be_nil
    user.destroy
    Car.count.must_equal 0
    Car.unscoped.count.must_equal 0 # does not include DestroyedAt
  end
end

describe 'restoring an activerecord instance' do
  it 'restores the records' do
    user = User.create(:destroyed_at => DateTime.current)
    User.all.must_be_empty
    user.reload
    user.restore
    user.destroyed_at.must_be_nil
    User.all.wont_be_empty
  end

  it 'runs the restore callbacks' do
    person = Person.create(:destroyed_at => DateTime.current)
    person.before_flag.wont_equal true
    person.after_flag.wont_equal true
    person.around_before_flag.wont_equal true
    person.around_after_flag.wont_equal true
    person.restore
    person.before_flag.must_equal true
    person.after_flag.must_equal true
    person.around_before_flag.must_equal true
    person.around_after_flag.must_equal true
  end

  it 'does not run validations on restore' do
    user = User.create
    user.validation_count.must_equal 1
    user.destroy
    user.validation_count.must_equal 1
    user.restore
    user.validation_count.must_equal 1
  end

  it 'restores relationships with DestroyedAt' do
    timestamp = DateTime.current
    user = User.create(:destroyed_at => timestamp)
    Profile.create(:destroyed_at => timestamp, :user => user)
    Profile.count.must_equal 0
    user.reload
    user.restore
    Profile.count.must_equal 1
  end

  it 'does not restore relationships without DestroyedAt' do
    user = User.create(:destroyed_at => DateTime.current, :show => Show.new(:destroyed_at => DateTime.current))
    Show.count.must_equal 0
    user.restore
    Show.count.must_equal 0
  end
end

describe 'destroying and restoring an activerecord instance' do
  it 'restores has_many relationship with DestroyedAt' do
    timestamp = DateTime.current
    user = User.create(:destroyed_at => timestamp) # has_many dinners
    Dinner.create(:destroyed_at => timestamp, :user => user)
    Dinner.count.must_equal 0
    user.reload
    user.restore
    Dinner.count.must_equal 1
  end

  it 'restores has_many through relationship with DestroyedAt' do
    timestamp = DateTime.current
    user = User.create(:destroyed_at => timestamp) # has_many cars through fleets
    car = Car.create # does not include #destroyed_at
    fleet = Fleet.create(:destroyed_at => timestamp, :car => car) # includes DestroyedAt
    user.fleets = [fleet]
    user.cars.count.must_equal 0
    user.reload
    user.restore
    user.cars.count.must_equal 1
  end

  it 'restores only the has_many dependent relationships destroyed when the parent was destroyed' do
    user = User.create
    dinner_one = Dinner.create(user: user, destroyed_at: Time.now - 1.day)
    dinner_two = Dinner.create(user: user)
    user.destroy
    user.reload # We have to reload the object before restoring in the test
                # because the in memory object has greater precision than
                # the database records
    user.restore
    user.dinners.wont_include dinner_one
    user.dinners.must_include dinner_two
  end

  it 'restores only the has_one dependent relationships destroyed when the parent was destroyed' do
    user = User.create
    profile_1 = Profile.create(user: user, destroyed_at: Time.now - 1.day)
    profile_2 = Profile.create(user: user)
    user.destroy
    user.restore
    user.profile.must_equal profile_2
    profile_1.reload
    profile_1.destroyed_at.wont_equal nil
  end

  it 'destroys and restores dependent relationships in a belongs_to relationship' do
    user = User.create
    show = Show.create(user: user)
    show.destroy
    show.reload
    user.reload
    user.destroyed_at.wont_equal nil # user is dependent on show
    show.restore
    user.reload
    user.destroyed_at.must_equal nil
  end
end

describe 'deleting a record' do
  it 'is not persisted after deletion' do
    user = User.create
    user.delete
    user.persisted?.must_equal false
  end

  it 'can delete destroyed records and they are marked as not persisted' do
    user = User.create
    user.destroy
    user.persisted?.must_equal true
    user.delete
    user.persisted?.must_equal false
  end
end

describe 'destroying an activerecord instance without DestroyedAt' do
  it 'does not impact ActiveRecord::Relation.destroy' do
    user = User.create
    pet  = Pet.create(user: user)
    user.pets.destroy(pet.id)
    user.pets.must_be_empty
  end
end
