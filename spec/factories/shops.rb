FactoryBot.define do
  factory :shop do
    sequence(:name) { |n| "Shop #{n}" }
    sequence(:slug) { |n| "shop-#{n}" }
  end
end
