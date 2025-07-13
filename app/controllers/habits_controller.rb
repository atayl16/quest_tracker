class HabitsController < ApplicationController
  def index
    # For now, get habits for the current_user (stubbed in tests)
    # Later this will be the authenticated user from sessions
    @habits = current_user&.habits || []
  end
end
