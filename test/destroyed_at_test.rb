require 'test_helper'

describe 'Destroying AR models' do
  after { User.delete_all }

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
    user = User.create(:destroyed_at => DateTime.now)
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
end
