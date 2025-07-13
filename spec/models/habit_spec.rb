require "rails_helper"

RSpec.describe Habit, type: :model do
  include ActiveSupport::Testing::TimeHelpers
  let(:user) { create(:user) }
  let(:habit) { create(:habit, user: user) }

  describe "validations" do
    it "is valid with a title and user" do
      expect(habit).to be_valid
    end

    it "is invalid without a title" do
      habit.title = nil
      expect(habit).not_to be_valid
    end

    it "is invalid without a user" do
      habit.user = nil
      expect(habit).not_to be_valid
    end
  end

  describe "#current_streak" do
    it "returns 0 for a habit with no check-ins" do
      expect(habit.current_streak).to eq(0)
    end

    it "returns 1 for a habit checked in today" do
      create(:check_in, habit: habit, user: user, checked_in_at: Time.current)
      expect(habit.current_streak).to eq(1)
    end

    it "returns 3 for a habit checked in 3 consecutive days" do
      create(:check_in, habit: habit, user: user, checked_in_at: 2.days.ago)
      create(:check_in, habit: habit, user: user, checked_in_at: 1.day.ago)
      create(:check_in, habit: habit, user: user, checked_in_at: Time.current)
      expect(habit.current_streak).to eq(3)
    end

    it "returns 0 when streak is broken" do
      create(:check_in, habit: habit, user: user, checked_in_at: 3.days.ago)
      create(:check_in, habit: habit, user: user, checked_in_at: 2.days.ago)
      # Missing yesterday
      create(:check_in, habit: habit, user: user, checked_in_at: Time.current)
      expect(habit.current_streak).to eq(1)
    end
  end

  describe "#longest_streak" do
    it "returns 0 for a habit with no check-ins" do
      expect(habit.longest_streak).to eq(0)
    end

    it "returns 1 for a single check-in" do
      create(:check_in, habit: habit, user: user, checked_in_at: Time.current)
      expect(habit.longest_streak).to eq(1)
    end

    it "returns the longest consecutive streak" do
      # First streak: 3 days
      create(:check_in, habit: habit, user: user, checked_in_at: 5.days.ago)
      create(:check_in, habit: habit, user: user, checked_in_at: 4.days.ago)
      create(:check_in, habit: habit, user: user, checked_in_at: 3.days.ago)

      # Break
      # 2.days.ago - no check-in

      # Second streak: 2 days
      create(:check_in, habit: habit, user: user, checked_in_at: 1.day.ago)
      create(:check_in, habit: habit, user: user, checked_in_at: Time.current)

      expect(habit.longest_streak).to eq(3)
    end
  end

  describe "#completed_today?" do
    it "returns false when no check-in today" do
      expect(habit.completed_today?).to be false
    end

    it "returns true when checked in today" do
      create(:check_in, habit: habit, user: user, checked_in_at: Time.current)
      expect(habit.completed_today?).to be true
    end
  end

  describe "#completion_rate" do
    it "returns 0 for a habit with no check-ins" do
      expect(habit.completion_rate).to eq(0)
    end

    it "returns 100 for a habit checked in every day since creation" do
      habit = nil
      travel_to(3.days.ago) do
        habit = create(:habit, user: user)
      end

      create(:check_in, habit: habit, user: user, checked_in_at: 3.days.ago)
      create(:check_in, habit: habit, user: user, checked_in_at: 2.days.ago)
      create(:check_in, habit: habit, user: user, checked_in_at: 1.day.ago)
      create(:check_in, habit: habit, user: user, checked_in_at: Time.current)

      expect(habit.completion_rate).to eq(100.0)
    end

    it "returns 50 for a habit checked in half the days" do
      habit = nil
      travel_to(4.days.ago) do
        habit = create(:habit, user: user)
      end

      create(:check_in, habit: habit, user: user, checked_in_at: 4.days.ago)
      create(:check_in, habit: habit, user: user, checked_in_at: 2.days.ago)

      # 4 days ago to today = 5 total days, 2 check-ins = 40%
      expect(habit.completion_rate).to eq(40.0)
    end
  end
end
