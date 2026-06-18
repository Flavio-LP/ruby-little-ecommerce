FactoryBot.define do
  factory :cart_item do
    transient do
      shop { create(:shop) }
    end

    cart { ActsAsTenant.with_tenant(shop) { create(:cart, shop: shop) } }
    product { ActsAsTenant.with_tenant(shop) { create(:product, shop: shop) } }
    quantity { 1 }
    unit_price_cents { 1_000 }
  end
end
