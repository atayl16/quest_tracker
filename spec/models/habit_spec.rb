require "rails_helper"

RSpec.describe Habit, type: :model do
  it "is valid with a title and user" do
    user = FactoryBot.create(:user)
    habit = Habit.new(title: "Take vitamins", user: user)
    expect(habit).to be_valid
  end

  it "is invalid without a title" do
    user = FactoryBot.create(:user)
    habit = Habit.new(title: nil, user: user)
    expect(habit).not_to be_valid
  end

  it "is invalid without a user" do
    habit = Habit.new(title: "Take vitamins", user: nil)
    expect(habit).not_to be_valid
  end
end
