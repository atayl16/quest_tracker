class Habit < ApplicationRecord
  belongs_to :user

  validates :title, presence: true

  scope :for_user, ->(user) { where(user: user) }
  scope :recent, -> { order(created_at: :desc) }
end
