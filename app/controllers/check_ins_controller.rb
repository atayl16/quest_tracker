class CheckInsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_habit

  def create
    @check_in = @habit.check_ins.build(
      user: current_user,
      checked_in_at: Time.current
    )

    if @check_in.save
      respond_to do |format|
        format.html { redirect_to habits_path, notice: "Habit checked in successfully!" }
        format.turbo_stream
      end
    else
      respond_to do |format|
        format.html { redirect_to habits_path, alert: "Could not check in habit." }
        format.turbo_stream { head :unprocessable_entity }
      end
    end
  end

  private

  def set_habit
    @habit = current_user.habits.find(params[:habit_id])
  end
end
