FactoryBot.define do
  factory :product do
    sequence(:name) { |n| "Product #{n}" }
    description { "A great product." }
    price_cents { 1_000 }
    sequence(:sku) { |n| "SKU-#{n}" }
    active { true }
    shop
  end
end
