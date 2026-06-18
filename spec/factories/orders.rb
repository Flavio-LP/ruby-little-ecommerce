FactoryBot.define do
  factory :order do
    shop
    status { :pending }
    total_cents { 1_000 }
  end
end
