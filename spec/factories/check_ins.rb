FactoryBot.define do
  factory :check_in do
    association :user
    association :habit
    checked_in_at { Time.current }
  end
end
