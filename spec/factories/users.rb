FactoryBot.define do
  factory :user do
    sequence(:username) { |n| "user#{n}" }
    password { DEFAULT_PASSWORD }
    password_confirmation { DEFAULT_PASSWORD }
  end
end
