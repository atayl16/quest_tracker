class CheckIn < ApplicationRecord
  belongs_to :user
  belongs_to :habit

  validates :user, presence: true
  validates :habit, presence: true
  validates :checked_in_at, presence: true
  validates :checked_in_at, uniqueness: { scope: [ :user_id, :habit_id ] }

  scope :for_date, ->(date) { where(checked_in_at: date.beginning_of_day..date.end_of_day) }
  scope :recent, -> { where(checked_in_at: 7.days.ago..Time.current) }

  def completed_today?
    checked_in_at.to_date == Date.current
  end
end
