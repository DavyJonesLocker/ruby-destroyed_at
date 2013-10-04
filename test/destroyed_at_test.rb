require 'test_helper'

describe 'Destroying AR models' do
  it 'Calling destroy on a model should only safe destroy record' do
    user = User.create
    user.destroy
    User.all.must_be_empty
    User.unscoped.all.wont_be_empty
  end

  it 'Destroying a model will set the timestamp it was destroyed at' do
    time = Time.now
    Timecop.freeze(time) do
      user = User.create
      user.destroy
      user.destroyed_at.must_equal time
    end
  end

  it 'can restore records' do
    user = User.create(:destroyed_at => DateTime.current)
    User.all.must_be_empty
    user.reload
    user.restore
    user.destroyed_at.must_be_nil
    User.all.wont_be_empty
  end

  it 'will run destroy callbacks' do
    person = Person.create
    person.before_flag.wont_equal true
    person.after_flag.wont_equal true
    person.destroy
    person.before_flag.must_equal true
    person.after_flag.must_equal true
  end

  it 'will run restore callbacks' do
    person = Person.create(:destroyed_at => DateTime.current)
    person.before_flag.wont_equal true
    person.after_flag.wont_equal true
    person.restore
    person.before_flag.must_equal true
    person.after_flag.must_equal true
  end

  it 'will properly destroy relations' do
    user = User.create(:profile => Profile.new, :car => Car.new)
    user.reload
    user.profile.wont_be_nil
    user.car.wont_be_nil
    user.destroy
    Profile.count.must_equal 0
    Profile.unscoped.count.must_equal 1
    Car.count.must_equal 0
    Car.unscoped.count.must_equal 0
  end

  it 'can restore relationships' do
    timestamp = DateTime.current
    user = User.create(:destroyed_at => timestamp)
    Profile.create(:destroyed_at => timestamp, :user => user)
    Profile.count.must_equal 0
    user.reload
    user.restore
    Profile.count.must_equal 1
  end

  it 'will not restore relationships that have no destroy dependency' do
    user = User.create(:destroyed_at => DateTime.current, :show => Show.new(:destroyed_at => DateTime.current))
    Show.count.must_equal 0
    user.restore
    Show.count.must_equal 0
  end

  it 'will respect has many associations' do
    timestamp = DateTime.current
    user = User.create(:destroyed_at => timestamp)
    Dinner.create(:destroyed_at => timestamp, :user => user)
    Dinner.count.must_equal 0
    user.reload
    user.restore
    Dinner.count.must_equal 1
  end

  it 'will respect has many through associations' do
    timestamp = DateTime.current
    user = User.create(:destroyed_at => timestamp)
    car = Car.create
    fleet = Fleet.create(:destroyed_at => timestamp, :car => car)
    user.fleets = [fleet]
    user.cars.count.must_equal 0
    user.reload
    user.restore
    user.cars.count.must_equal 1
  end

  it 'properly sets #destroyed?' do
    user = User.create
    user.destroy
    user.destroyed?.must_equal true
    user = User.unscoped.last
    user.destroyed?.must_equal true
    user.restore
    user.destroyed?.must_equal false
  end

  it 'properly selects columns' do
    User.create
    User.select(:id).must_be_kind_of ActiveRecord::Relation
  end

  it 'only destroys and restores related dependents' do
    2.times do
       User.create(dinners: [Dinner.create, Dinner.create, Dinner.create])
    end

    User.first.destroy
    Dinner.count.must_equal 3
    User.first.destroy
    Dinner.count.must_equal 0
    User.unscoped.first.restore
    Dinner.count.must_equal 3
  end

  it 'skips callbacks' do
    user = User.create
    user.destroy
    user.before_update_count.must_equal nil
    user.restore
    user.before_update_count.must_equal nil
  end

  it 'skips validations on restore' do
    user = User.create
    user.validation_count.must_equal 1
    user.destroy
    user.validation_count.must_equal 1
    user.restore
    user.validation_count.must_equal 1
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

  it 'only restores dependencies destroyed with parent with has many' do
    user = User.create
    dinner_one = Dinner.create(user: user, destroyed_at: Time.now - 1.day)
    dinner_two = Dinner.create(user: user)
    user.destroy
    user.restore
    user.dinners.include?(dinner_one).must_equal false
    user.dinners.include?(dinner_two).must_equal true
  end

  it 'only restores dependencies destroyed with parent with has one' do
    user = User.create
    profile_1 = Profile.create(user: user, destroyed_at: Time.now - 1.day)
    profile_2 = Profile.create(user: user)
    user.destroy
    user.restore
    user.profile.must_equal profile_2
    profile_1.reload
    profile_1.destroyed_at.wont_equal nil
  end
end
