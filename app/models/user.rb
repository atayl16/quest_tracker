class User < ApplicationRecord
  has_many :habits, dependent: :destroy

  validates :email, presence: true, uniqueness: true
end
