class CompleteHabit
  attr_reader :user, :habit, :check_in, :errors

  def initialize(user:, habit:)
    @user = user
    @habit = habit
    @errors = []
  end

  def call
    return failure_result unless valid_inputs?

    @check_in = build_check_in
    
    if @check_in.save
      success_result
    else
      failure_result_with_errors
    end
  end

  def success?
    @check_in&.persisted?
  end

  private

  def valid_inputs?
    if user.nil?
      @errors << "User is required"
      return false
    end

    if habit.nil?
      @errors << "Habit is required"
      return false
    end

    unless habit.user == user
      @errors << "Habit does not belong to user"
      return false
    end

    true
  end

  def build_check_in
    habit.check_ins.build(
      user: user,
      checked_in_at: Time.current
    )
  end

  def success_result
    OpenStruct.new(
      success?: true,
      check_in: @check_in,
      errors: []
    )
  end

  def failure_result
    OpenStruct.new(
      success?: false,
      check_in: nil,
      errors: @errors
    )
  end

  def failure_result_with_errors
    OpenStruct.new(
      success?: false,
      check_in: @check_in,
      errors: @check_in.errors.full_messages
    )
  end
end 
