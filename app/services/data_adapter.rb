class DataAdapter
  def self.current
    Rails.env.production? ? LocalStorageAdapter.new : DatabaseAdapter.new
  end

  # Base adapter interface
  def find_habits_for_user(user_id)
    raise NotImplementedError
  end

  def create_habit(attributes)
    raise NotImplementedError
  end

  def delete_habit(habit_id, user_id)
    raise NotImplementedError
  end

  def create_check_in(habit_id, user_id)
    raise NotImplementedError
  end

  def delete_check_in(check_in_id, user_id)
    raise NotImplementedError
  end

  def find_user_by_credentials(username, password)
    raise NotImplementedError
  end

  def create_user(attributes)
    raise NotImplementedError
  end
end
