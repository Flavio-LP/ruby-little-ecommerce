require "rails_helper"
require "active_job/test_helper"

RSpec.describe Checkout::CreateOrder do
  include ActiveJob::TestHelper

  let(:shop) { create(:shop) }
  let(:product) { ActsAsTenant.with_tenant(shop) { create(:product, shop: shop, price_cents: 1_000) } }
  let(:cart) { ActsAsTenant.with_tenant(shop) { create(:cart, shop: shop) } }

  before do
    Carts::AddItem.call(cart: cart, product: product, quantity: 2)
  end

  it "creates an order with line items snapshotting the cart contents" do
    result = ActsAsTenant.with_tenant(shop) { described_class.call(cart: cart) }

    expect(result).to be_success
    expect(result.order.status).to eq("pending")
    expect(result.order.total_cents).to eq(2_000)
    expect(result.order.line_items.count).to eq(1)
    expect(result.order.line_items.first.unit_price_cents).to eq(1_000)
  end

  it "clears the cart on success" do
    ActsAsTenant.with_tenant(shop) { described_class.call(cart: cart) }

    expect(cart.cart_items.reload).to be_empty
  end

  it "enqueues an OrderConfirmationJob" do
    expect { ActsAsTenant.with_tenant(shop) { described_class.call(cart: cart) } }
      .to have_enqueued_job(OrderConfirmationJob)
  end

  it "rejects checkout with an empty cart" do
    empty_cart = ActsAsTenant.with_tenant(shop) { create(:cart, shop: shop) }

    result = ActsAsTenant.with_tenant(shop) { described_class.call(cart: empty_cart) }

    expect(result).to be_failure
    expect(Order.unscoped.where(shop: shop).count).to eq(0)
  end
end
