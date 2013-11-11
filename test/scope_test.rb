require 'test_helper'

describe 'Scopes' do
  let(:user)     { User.create! }
  let(:fleet_1)  { user.fleets.create! }
  let(:fleet_2)  { user.fleets.create! }
  let(:fleet_3)  { Fleet.create! }
  let(:fleet_4)  { Fleet.create! }

  before do
    fleet_1
    fleet_2.destroy
    fleet_3
    fleet_4.destroy
  end

  describe '.destroyed' do
    context 'Called on model' do
      let(:destroyed_fleets) { Fleet.destroyed }

      it 'returns records that have been destroyed' do
        destroyed_fleets.must_include fleet_2
        destroyed_fleets.must_include fleet_4
      end

      it 'does not return current records' do
        destroyed_fleets.wont_include fleet_1
        destroyed_fleets.wont_include fleet_3
      end
    end

    context 'Called on relation' do
      let(:destroyed_fleets) { user.fleets.destroyed }

      it 'returns destroyed records beloning in the relation' do
        destroyed_fleets.must_include fleet_2
      end

      it 'does not return destroyed records that are outside the relation' do
        destroyed_fleets.wont_include fleet_4
      end

      it 'does not return current records in the relation' do
        destroyed_fleets.wont_include fleet_1
      end

      it 'does not return current records that are outside the relation' do
        destroyed_fleets.wont_include fleet_3
      end
    end
  end
end
