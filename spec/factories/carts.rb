FactoryBot.define do
  factory :cart do
    shop
    sequence(:guest_token) { |n| "guest-token-#{n}" }
  end
end
