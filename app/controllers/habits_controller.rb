class HabitsController < ApplicationController
  def index
    @habits = Habit.for_user(current_user).recent
  end

  private

  # Temporary stub for demo/testing
  def current_user
    User.first || User.create!(email: "demo@example.com")
  end
end
