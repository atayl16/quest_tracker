class HabitsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_habit, only: [ :destroy ]

  def index
    # For now, get habits for the current_user (stubbed in tests)
    # Later this will be the authenticated user from sessions
    @habits = (current_user&.habits || []).includes(:check_ins)

    respond_to do |format|
      format.html do
        # Render React version if ui=react parameter is present
        if params[:ui] == "react"
          render "react_index"
        end
      end
      format.json { render json: @habits.as_json(include: :check_ins, methods: [ :current_streak, :longest_streak ]) }
    end
  end

  def create
    @habit = current_user.habits.build(habit_params)

    respond_to do |format|
      if @habit.save
        format.html { redirect_to habits_path, notice: "Habit created successfully!" }
        format.json { render json: @habit.as_json(include: :check_ins, methods: [ :current_streak, :longest_streak ]), status: :created }
      else
        @habits = current_user.habits
        format.html { render :index, status: :unprocessable_entity }
        format.json { render json: { errors: @habit.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @habit.destroy
    respond_to do |format|
      format.html { redirect_to habits_path, notice: "Habit deleted successfully!" }
      format.turbo_stream { flash.now[:notice] = "Habit deleted successfully!" }
      format.json { head :no_content }
    end
  end

  private

  def set_habit
    @habit = current_user.habits.find(params[:id])
  end

  def habit_params
    params.require(:habit).permit(:title)
  end
end
