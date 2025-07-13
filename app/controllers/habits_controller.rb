class HabitsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_habit, only: [ :destroy ]

  def index
    # For now, get habits for the current_user (stubbed in tests)
    # Later this will be the authenticated user from sessions
    @habits = (current_user&.habits || []).includes(:check_ins)
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

  def destroy
    if @habit.user == current_user
      @habit.destroy
      respond_to do |format|
        format.html { redirect_to habits_path, notice: "Habit deleted successfully!" }
        format.turbo_stream { flash.now[:notice] = "Habit deleted successfully!" }
      end
    else
      head :not_found
    end
  end

  private

  def set_habit
    @habit = Habit.find(params[:id])
  end

  def habit_params
    params.require(:habit).permit(:title)
  end
end
