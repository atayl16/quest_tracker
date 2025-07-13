class User < ApplicationRecord
  has_secure_password

  has_many :habits, dependent: :destroy
  has_many :check_ins, dependent: :destroy

  validates :username, presence: true, uniqueness: true
  validates :password, presence: true, confirmation: true
end
