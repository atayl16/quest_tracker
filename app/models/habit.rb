class Habit < ApplicationRecord
  belongs_to :user
  has_many :check_ins, dependent: :destroy
  validates :title, presence: true

  def current_streak
    streak = 0
    current_date = Date.current

    while check_ins.for_date(current_date).exists?
      streak += 1
      current_date -= 1.day
    end

    streak
  end

  def longest_streak
    # This is a simplified calculation - in a real app you might want to store this
    # For now, we'll calculate it on the fly
    max_streak = 0
    current_streak = 0
    dates = check_ins.pluck(:checked_in_at).map(&:to_date).sort

    return 0 if dates.empty?

    dates.each_with_index do |date, index|
      if index == 0 || date == dates[index - 1] + 1.day
        current_streak += 1
        max_streak = [ max_streak, current_streak ].max
      else
        current_streak = 1
      end
    end

    max_streak
  end

  def completed_today?
    check_ins.for_date(Date.current).exists?
  end

  # Get today's check-in for a specific user
  # This method works with preloaded check_ins to avoid N+1 queries
  def todays_check_in_for_user(user)
    return nil unless user

    check_ins.find { |check_in|
      check_in.user_id == user.id &&
      check_in.checked_in_at.to_date == Date.current
    }
  end
end
