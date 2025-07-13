class CheckInsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_habit

  def create
    result = CompleteHabit.new(user: current_user, habit: @habit).call

    if result.success?
      @check_in = result.check_in
      respond_to do |format|
        format.html { redirect_to habits_path, notice: "Habit checked in successfully!" }
        format.turbo_stream
      end
    else
      respond_to do |format|
        format.html { redirect_to habits_path, alert: result.errors.join(", ") }
        format.turbo_stream { head :unprocessable_entity }
      end
    end
  end

  def destroy
    @check_in = @habit.check_ins.find_by(id: params[:id], user: current_user)
    if @check_in
      @check_in.destroy
      @habit.reload
      respond_to do |format|
        format.html { redirect_to habits_path, notice: "Check-in undone!" }
        format.turbo_stream { flash.now[:notice] = "Check-in undone!" }
      end
    else
      head :not_found
    end
  end

  private

  def set_habit
    @habit = current_user.habits.find(params[:habit_id])
  end
end
