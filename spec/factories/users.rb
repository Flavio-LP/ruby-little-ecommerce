FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    role { :customer }

    trait :seller do
      role { :seller }
      shop
    end
  end
end
