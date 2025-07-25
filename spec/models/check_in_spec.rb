require "rails_helper"

RSpec.describe CheckIn, type: :model do
  describe "associations" do
    it "belongs to user" do
      check_in = build(:check_in)
      expect(check_in.user).to be_present
    end

    it "belongs to habit" do
      check_in = build(:check_in)
      expect(check_in.habit).to be_present
    end
  end

  describe "validations" do
    it "validates presence of user" do
      check_in = build(:check_in, user: nil)
      expect(check_in).not_to be_valid
      expect(check_in.errors[:user]).to include("must exist")
    end

    it "validates presence of habit" do
      check_in = build(:check_in, habit: nil)
      expect(check_in).not_to be_valid
      expect(check_in.errors[:habit]).to include("must exist")
    end

    it "validates presence of checked_in_at" do
      check_in = build(:check_in, checked_in_at: nil)
      expect(check_in).not_to be_valid
      expect(check_in.errors[:checked_in_at]).to include("can't be blank")
    end

    it "validates uniqueness of check-ins per day scoped to user and habit" do
      user = create(:user)
      habit = create(:habit, user: user)
      today = Date.current

      # Create a check-in for today at 9 AM
      create(:check_in, user: user, habit: habit, checked_in_at: today.beginning_of_day + 9.hours)

      # Try to create another check-in for the same day at 6 PM
      duplicate_check_in = build(:check_in, user: user, habit: habit, checked_in_at: today.beginning_of_day + 18.hours)

      expect(duplicate_check_in).not_to be_valid
      expect(duplicate_check_in.errors[:checked_in_at]).to include("You have already checked in for this habit today")
    end

    it "allows check-ins on different days for the same user and habit" do
      user = create(:user)
      habit = create(:habit, user: user)
      today = Date.current
      yesterday = 1.day.ago.to_date

      # Create a check-in for yesterday
      create(:check_in, user: user, habit: habit, checked_in_at: yesterday.beginning_of_day + 10.hours)

      # Create a check-in for today (should be valid)
      today_check_in = build(:check_in, user: user, habit: habit, checked_in_at: today.beginning_of_day + 10.hours)

      expect(today_check_in).to be_valid
    end
  end

  describe "scopes" do
    let(:user) { create(:user) }
    let(:habit) { create(:habit, user: user) }

    before do
      # Create check-ins for different dates
      create(:check_in, user: user, habit: habit, checked_in_at: Date.current)
      create(:check_in, user: user, habit: habit, checked_in_at: 2.days.ago)
      create(:check_in, user: user, habit: habit, checked_in_at: 1.week.ago)
    end

    describe ".for_date" do
      it "returns check-ins for a specific date" do
        check_ins = CheckIn.for_date(Date.current)
        expect(check_ins.count).to eq(1)
        expect(check_ins.first.checked_in_at.to_date).to eq(Date.current)
      end
    end

    describe ".recent" do
      it "returns check-ins from the last 7 days" do
        recent_check_ins = CheckIn.recent
        expect(recent_check_ins.count).to eq(2) # today and 2 days ago
      end
    end
  end

  describe "instance methods" do
    let(:check_in) { create(:check_in) }

    describe "#completed_today?" do
      it "returns true if checked in today" do
        today_check_in = create(:check_in, checked_in_at: Time.current)
        expect(today_check_in.completed_today?).to be true
      end

      it "returns false if checked in on a different day" do
        old_check_in = create(:check_in, checked_in_at: 2.days.ago)
        expect(old_check_in.completed_today?).to be false
      end
    end
  end
end
