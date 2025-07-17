class LocalStorageAdapter < DataAdapter
  def find_habits_for_user(user_id)
    # In production, we'll use JavaScript to read from localStorage
    # For now, return an empty array - the JavaScript will handle this
    []
  end

  def create_habit(attributes)
    # This will be handled by JavaScript in production
    if attributes[:title].blank?
      { success: false, errors: ["Title can't be blank"] }
    else
      { success: true, habit: { id: SecureRandom.uuid, title: attributes[:title] } }
    end
  end

  def delete_habit(habit_id, user_id)
    # This will be handled by JavaScript in production
    { success: true }
  end

  def create_check_in(habit_id, user_id)
    # This will be handled by JavaScript in production
    { success: true, check_in: { id: SecureRandom.uuid, checked_in_at: Time.current } }
  end

  def delete_check_in(check_in_id, user_id)
    # This will be handled by JavaScript in production
    { success: true }
  end

  def find_user_by_credentials(username, password)
    # In production, we'll use a simple demo user
    return nil unless username == "demo" && password == "password"
    
    # Return a mock user object
    OpenStruct.new(
      id: 1,
      username: "demo",
      email: "demo@example.com"
    )
  end

  def create_user(attributes)
    # In production, we'll use localStorage for user management
    { success: true, user: OpenStruct.new(id: SecureRandom.uuid, username: attributes[:username]) }
  end
end 
