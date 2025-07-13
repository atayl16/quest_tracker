class Habit < ApplicationRecord
  belongs_to :user
  has_many :check_ins, dependent: :destroy
  validates :title, presence: true
end
