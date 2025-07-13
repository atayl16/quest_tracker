class HabitsController < ApplicationController
  before_action :authenticate_user!

  def index
    # For now, get habits for the current_user (stubbed in tests)
    # Later this will be the authenticated user from sessions
    @habits = current_user&.habits || []
  end

  def create
    @habit = current_user.habits.build(habit_params)

    if @habit.save
      redirect_to habits_path, notice: "Habit created successfully!"
    else
      @habits = current_user.habits
      render :index, status: :unprocessable_entity
    end
  end

  private

  def habit_params
    params.require(:habit).permit(:title)
  end
end
