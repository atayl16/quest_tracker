class CheckIn < ApplicationRecord
  belongs_to :user
  belongs_to :habit

  validates :checked_in_at, presence: true
  validate :one_check_in_per_day

  scope :for_date, ->(date) { where(checked_in_at: date.beginning_of_day..date.end_of_day) }
  scope :recent, -> { where(checked_in_at: 7.days.ago..Time.current) }

  def completed_today?
    checked_in_at&.to_date == Date.current
  end

  private

  def one_check_in_per_day
    return unless user && habit && checked_in_at

    date = checked_in_at.to_date
    existing_check_in = CheckIn.where(user: user, habit: habit)
                              .where(checked_in_at: date.beginning_of_day..date.end_of_day)
                              .where.not(id: id)
                              .exists?

    if existing_check_in
      errors.add(:checked_in_at, "You have already checked in for this habit today")
    end
  end
end
