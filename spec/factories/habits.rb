FactoryBot.define do
  factory :habit do
    sequence(:title) { |n| "Habit #{n}" }
    association :user
  end
end
