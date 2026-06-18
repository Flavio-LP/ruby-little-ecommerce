require "rails_helper"
require "active_job/test_helper"

RSpec.describe "Checkout", type: :feature do
  include ActiveJob::TestHelper

  it "converts a cart into an order and shows the confirmation page" do
    shop = create(:shop)
    ActsAsTenant.with_tenant(shop) { create(:product, shop: shop, name: "Widget", price_cents: 1_000) }

    visit "/#{shop.slug}/produtos"
    click_button "Add to cart"
    visit "/#{shop.slug}/cart"

    expect {
      click_button "Checkout"
    }.to have_enqueued_job(OrderConfirmationJob)

    expect(page).to have_content("Thank you for your order!")
    expect(page).to have_content("Widget")
  end

  it "rejects checkout with an empty cart and keeps the customer on the cart page" do
    shop = create(:shop)

    visit "/#{shop.slug}/cart"
    page.driver.submit :post, "/#{shop.slug}/checkout", {}

    expect(page).to have_content("Your cart is empty")
  end
end
