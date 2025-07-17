class Habit < ApplicationRecord
  belongs_to :user
  has_many :check_ins, dependent: :destroy
  validates :title, presence: true

  def current_streak
    # Use memoization to avoid recalculating
    @current_streak ||= calculate_current_streak
  end

  def longest_streak
    # Use memoization to avoid recalculating
    @longest_streak ||= calculate_longest_streak
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

  private

  def calculate_current_streak
    # Use preloaded check_ins to avoid N+1 queries
    dates = check_ins.map(&:checked_in_at).map(&:to_date).sort.reverse
    return 0 if dates.empty?

    streak = 0
    current_date = Date.current

    dates.each do |date|
      if date == current_date
        streak += 1
        current_date -= 1.day
      elsif date < current_date
        break
      end
      # If date > current_date, just skip (shouldn't happen with unique dates)
    end

    streak
  end

  def calculate_longest_streak
    # Use preloaded check_ins to avoid N+1 queries
    max_streak = 0
    current_streak = 0
    dates = check_ins.map(&:checked_in_at).map(&:to_date).sort

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
end
