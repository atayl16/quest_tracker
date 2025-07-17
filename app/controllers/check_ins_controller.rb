class CheckInsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_habit

  def create
    adapter = DataAdapter.current
    result = adapter.create_check_in(@habit.id, current_user.id)

    if result[:success]
      @check_in = result[:check_in]
      respond_to do |format|
        format.html { redirect_to habits_path, notice: "Habit checked in successfully!" }
        format.turbo_stream
        format.json { render json: @check_in, status: :created }
      end
    else
      respond_to do |format|
        format.html { redirect_to habits_path, alert: result[:error] }
        format.turbo_stream { head :unprocessable_entity }
        format.json { render json: { errors: [result[:error]] }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    adapter = DataAdapter.current
    result = adapter.delete_check_in(params[:id], current_user.id)

    if result[:success]
      respond_to do |format|
        format.html { redirect_to habits_path, notice: "Check-in undone!" }
        format.turbo_stream { flash.now[:notice] = "Check-in undone!" }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { head :not_found }
        format.json { head :not_found }
      end
    end
  end

  private

  def set_habit
    adapter = DataAdapter.current
    @habits = adapter.find_habits_for_user(current_user.id)
    @habit = @habits.find { |h| h.id.to_s == params[:habit_id] }
    
    unless @habit
      redirect_to habits_path, alert: "Habit not found"
    end
  end
end
