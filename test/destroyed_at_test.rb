require 'test_helper'

describe 'Destroying AR models' do
  it 'Calling destroy on a model should only safe destroy record' do
    user = User.create
    user.destroy
    User.all.must_be_empty
    User.unscoped.all.wont_be_empty
  end

  it 'Destroying a model will set the timestamp it was destroyed at' do
    date = DateTime.current
    Timecop.freeze(date) do
      user = User.create
      user.destroy
      user.destroyed_at.inspect.must_equal date.inspect
    end
  end

  it 'can undestroy records' do
    user = User.create(:destroyed_at => DateTime.current)
    User.all.must_be_empty
    user.reload
    user.undestroy
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

  it 'can undestroy relationships' do
    user = User.create(:destroyed_at => DateTime.current)
    Profile.create(:destroyed_at => DateTime.current, :user => user)
    Profile.count.must_equal 0
    user.undestroy
    Profile.count.must_equal 1
  end

  it 'will not undestroy relationships that have no destroy dependency' do
    user = User.create(:destroyed_at => DateTime.current, :show => Show.new(:destroyed_at => DateTime.current))
    Show.count.must_equal 0
    user.undestroy
    Show.count.must_equal 0
  end

  it 'will respect has many associations' do
    user = User.create(:destroyed_at => DateTime.current)
    Dinner.create(:destroyed_at => DateTime.current, :user => user)
    Dinner.count.must_equal 0
    user.undestroy
    Dinner.count.must_equal 1
  end

  it 'will respect has many through associations' do
    #user = User.create(:destroyed_at => DateTime.current, :fleets => [Fleet.new(:destroyed_at => DateTime.current, :car => Car.new)])
    user = User.create(:destroyed_at => DateTime.current)
    car = Car.create
    fleet = Fleet.create(:destroyed_at => DateTime.current, :car => car)
    user.fleets = [fleet]
    user.cars.count.must_equal 0
    user.undestroy
    user.cars.count.must_equal 1
  end

  it 'properly sets #destroyed?' do
    user = User.create
    user.destroy
    user.destroyed?.must_equal true
    user = User.unscoped.last
    user.destroyed?.must_equal true
    user.undestroy
    user.destroyed?.must_equal false
  end
end
