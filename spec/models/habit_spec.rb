require 'rails_helper'

RSpec.describe Habit, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:title) }
  end

  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:habit)).to be_valid
    end
  end

  describe 'scopes' do
    let(:user) { create(:user) }
    let!(:habit1) { create(:habit, user: user, created_at: 1.day.ago) }
    let!(:habit2) { create(:habit, user: user, created_at: 2.days.ago) }

    describe '.for_user' do
      it 'returns habits for a specific user' do
        other_user = create(:user)
        other_habit = create(:habit, user: other_user)

        expect(Habit.for_user(user)).to include(habit1, habit2)
        expect(Habit.for_user(user)).not_to include(other_habit)
      end
    end

    describe '.recent' do
      it 'returns habits ordered by most recent first' do
        expect(Habit.recent.to_a).to eq([ habit1, habit2 ])
      end
    end
  end
end
