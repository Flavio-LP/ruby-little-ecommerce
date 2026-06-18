require 'rails_helper'

RSpec.describe Cart, type: :model do
  it "is scoped to a shop via acts_as_tenant" do
    shop = create(:shop)
    cart = ActsAsTenant.with_tenant(shop) { create(:cart, shop: shop) }
    expect(cart.shop).to eq(shop)
  end

  it "sums cart_items into total_cents" do
    shop = create(:shop)
    cart = ActsAsTenant.with_tenant(shop) { create(:cart, shop: shop) }
    product_a = ActsAsTenant.with_tenant(shop) { create(:product, shop: shop, price_cents: 1_000) }
    product_b = ActsAsTenant.with_tenant(shop) { create(:product, shop: shop, price_cents: 500) }
    create(:cart_item, cart: cart, product: product_a, quantity: 2, unit_price_cents: 1_000)
    create(:cart_item, cart: cart, product: product_b, quantity: 1, unit_price_cents: 500)

    expect(cart.total_cents).to eq(2_500)
  end

  it "increments quantity instead of creating a duplicate row when the same product is added twice" do
    shop = create(:shop)
    cart = ActsAsTenant.with_tenant(shop) { create(:cart, shop: shop) }
    product = ActsAsTenant.with_tenant(shop) { create(:product, shop: shop, price_cents: 1_000) }

    item = cart.cart_items.find_or_initialize_by(product: product)
    item.unit_price_cents ||= product.price_cents
    item.quantity = (item.new_record? ? 0 : item.quantity) + 1
    item.save!

    item_again = cart.cart_items.find_or_initialize_by(product: product)
    item_again.unit_price_cents ||= product.price_cents
    item_again.quantity = (item_again.new_record? ? 0 : item_again.quantity) + 1
    item_again.save!

    expect(cart.cart_items.count).to eq(1)
    expect(cart.cart_items.first.quantity).to eq(2)
  end
end
