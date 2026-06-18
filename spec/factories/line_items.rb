FactoryBot.define do
  factory :line_item do
    transient do
      shop { create(:shop) }
    end

    order { ActsAsTenant.with_tenant(shop) { create(:order, shop: shop) } }
    product { ActsAsTenant.with_tenant(shop) { create(:product, shop: shop) } }
    quantity { 1 }
    unit_price_cents { 1_000 }
  end
end
