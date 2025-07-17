# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create demo user if it doesn't exist
demo_user = User.find_or_create_by!(username: 'demo') do |user|
  user.password = 'password'
  user.password_confirmation = 'password'
end

# Sample habits for the demo user
sample_habits = [
  {
    title: "Morning Meditation",
    check_ins: [
      { checked_in_at: 2.days.ago },
      { checked_in_at: 1.day.ago },
      { checked_in_at: Date.current }
    ]
  },
  {
    title: "Read 30 Minutes",
    check_ins: [
      { checked_in_at: 5.days.ago },
      { checked_in_at: 4.days.ago },
      { checked_in_at: 3.days.ago },
      { checked_in_at: 2.days.ago },
      { checked_in_at: 1.day.ago }
    ]
  },
  {
    title: "Drink 8 Glasses of Water",
    check_ins: [
      { checked_in_at: 1.day.ago },
      { checked_in_at: Date.current }
    ]
  },
  {
    title: "Exercise for 20 Minutes",
    check_ins: [
      { checked_in_at: 3.days.ago },
      { checked_in_at: 2.days.ago }
    ]
  },
  {
    title: "Practice Guitar",
    check_ins: [
      { checked_in_at: 7.days.ago },
      { checked_in_at: 6.days.ago },
      { checked_in_at: 5.days.ago },
      { checked_in_at: 4.days.ago },
      { checked_in_at: 3.days.ago },
      { checked_in_at: 2.days.ago },
      { checked_in_at: 1.day.ago },
      { checked_in_at: Date.current }
    ]
  }
]

# Create habits and check-ins
sample_habits.each do |habit_data|
  habit = Habit.find_or_create_by!(title: habit_data[:title], user: demo_user)

  habit_data[:check_ins].each do |check_in_data|
    CheckIn.find_or_create_by!(
      habit: habit,
      user: demo_user,
      checked_in_at: check_in_data[:checked_in_at]
    )
  end
end

puts "✅ Seeded demo user and #{sample_habits.length} sample habits with check-ins!"
puts "🔑 Demo credentials: demo / password"
