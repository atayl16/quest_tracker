class DatabaseAdapter < DataAdapter
  def find_habits_for_user(user_id)
    user = User.find(user_id)
    user.habits.includes(:check_ins)
  end

  def create_habit(attributes)
    user = User.find(attributes[:user_id])
    habit = user.habits.build(title: attributes[:title])

    if habit.save
      { success: true, habit: habit }
    else
      { success: false, errors: habit.errors.full_messages }
    end
  rescue ActiveRecord::RecordNotFound
    { success: false, errors: [ "User not found" ] }
  end

  def delete_habit(habit_id, user_id)
    habit = User.find(user_id).habits.find(habit_id)
    habit.destroy
    { success: true }
  rescue ActiveRecord::RecordNotFound
    { success: false, error: "Habit not found" }
  end

  def create_check_in(habit_id, user_id)
    habit = User.find(user_id).habits.find(habit_id)

    # Check if already checked in today
    existing_check_in = habit.check_ins.find_by(
      user_id: user_id,
      checked_in_at: Time.zone.today.all_day
    )

    if existing_check_in
      { success: false, error: "Already checked in today" }
    else
      check_in = habit.check_ins.create!(
        user_id: user_id,
        checked_in_at: Time.current
      )
      { success: true, check_in: check_in }
    end
  rescue ActiveRecord::RecordNotFound
    { success: false, error: "Habit not found" }
  end

  def delete_check_in(check_in_id, user_id)
    check_in = CheckIn.joins(:habit).where(
      id: check_in_id,
      user_id: user_id
    ).first

    if check_in
      check_in.destroy
      { success: true }
    else
      { success: false, error: "Check-in not found" }
    end
  end

  def find_user_by_credentials(username, password)
    user = User.find_by(username: username)
    return nil unless user&.authenticate(password)
    user
  end

  def create_user(attributes)
    user = User.new(attributes)

    if user.save
      { success: true, user: user }
    else
      { success: false, errors: user.errors.full_messages }
    end
  end
end
