require "rails_helper"

RSpec.describe Carts::AddItem do
  let(:shop) { create(:shop) }
  let(:cart) { ActsAsTenant.with_tenant(shop) { create(:cart, shop: shop) } }
  let(:product) { ActsAsTenant.with_tenant(shop) { create(:product, shop: shop, price_cents: 1_000) } }

  it "creates a cart_item with a price snapshot" do
    result = described_class.call(cart: cart, product: product, quantity: 1)

    expect(result).to be_success
    expect(result.cart_item.unit_price_cents).to eq(1_000)
    expect(result.cart_item.quantity).to eq(1)
  end

  it "increments quantity when called again for the same product" do
    described_class.call(cart: cart, product: product, quantity: 1)
    result = described_class.call(cart: cart, product: product, quantity: 2)

    expect(result.cart_item.quantity).to eq(3)
    expect(cart.cart_items.count).to eq(1)
  end

  it "keeps the original price snapshot even if the product price changes later" do
    described_class.call(cart: cart, product: product, quantity: 1)
    product.update!(price_cents: 2_000)

    result = described_class.call(cart: cart, product: product, quantity: 1)

    expect(result.cart_item.unit_price_cents).to eq(1_000)
  end

  it "rejects an inactive product" do
    product.update!(active: false)

    result = described_class.call(cart: cart, product: product, quantity: 1)

    expect(result).to be_failure
  end

  it "rejects a product from a different shop than the cart's shop" do
    other_shop = create(:shop)
    other_product = ActsAsTenant.with_tenant(other_shop) { create(:product, shop: other_shop) }

    result = described_class.call(cart: cart, product: other_product, quantity: 1)

    expect(result).to be_failure
  end
end
