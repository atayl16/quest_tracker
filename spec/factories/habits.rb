FactoryBot.define do
  factory :habit do
    title { "MyString" }
    association :user
  end
end
