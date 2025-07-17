class HabitsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_habit, only: [ :destroy ]

  class ControllerErrorMock
    def initialize(errors)
      @errors = errors
    end
    def any?
      true
    end
    def full_messages_for(_field)
      @errors
    end
    def full_messages
      @errors
    end
  end

  def index
    adapter = DataAdapter.current
    @habits = adapter.find_habits_for_user(current_user.id)

    respond_to do |format|
      format.html do
        # Render React version if ui=react parameter is present
        if params[:ui] == "react"
          render "react_index"
        end
      end
      format.json {
        habits_with_streaks = @habits.map do |habit|
          if Rails.env.production?
            # Use localStorage service for streaks in production
            habit_data = habit.as_json
            habit_data[:current_streak] = 0 # Will be calculated by JavaScript
            habit_data[:longest_streak] = 0 # Will be calculated by JavaScript
            habit_data
          else
            habit.as_json(include: :check_ins, methods: [ :current_streak, :longest_streak ])
          end
        end
        render json: habits_with_streaks
      }
    end
  end

  def create
    adapter = DataAdapter.current
    result = adapter.create_habit(
      title: habit_params[:title],
      user_id: current_user.id
    )

    respond_to do |format|
      if result[:success]
        format.html { redirect_to habits_path }
        format.json { render json: result[:habit], status: :created }
      else
        @habits = adapter.find_habits_for_user(current_user.id)
        format.html {
          @habit = OpenStruct.new(errors: ControllerErrorMock.new(result[:errors]))
          render :index, status: :unprocessable_entity
        }
        format.json { render json: { errors: result[:errors] }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    adapter = DataAdapter.current
    result = adapter.delete_habit(params[:id], current_user.id)

    respond_to do |format|
      if result[:success]
        format.html { redirect_to habits_path }
        format.turbo_stream { flash.now[:notice] = "Habit deleted successfully!" }
        format.json { head :no_content }
      else
        format.html { head :not_found }
        format.json { render json: { error: result[:error] }, status: :not_found }
      end
    end
  end

  private

  def set_habit
    adapter = DataAdapter.current
    @habits = adapter.find_habits_for_user(current_user.id)
    @habit = @habits.find { |h| h.id.to_s == params[:id] }
    unless @habit
      respond_to do |format|
        format.html { head :not_found }
        format.json { render json: { error: "Habit not found" }, status: :not_found }
      end
    end
  end

  def habit_params
    params.require(:habit).permit(:title)
  end
end
