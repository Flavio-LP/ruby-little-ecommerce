require "rails_helper"

RSpec.describe "Public storefront", type: :feature do
  it "only lists active products belonging to the current shop" do
    shop_a = create(:shop)
    shop_b = create(:shop)

    visible = ActsAsTenant.with_tenant(shop_a) { create(:product, shop: shop_a, name: "Visible Widget") }
    ActsAsTenant.with_tenant(shop_a) { create(:product, shop: shop_a, name: "Inactive Widget", active: false) }
    ActsAsTenant.with_tenant(shop_b) { create(:product, shop: shop_b, name: "Other Shop Widget") }

    visit "/#{shop_a.slug}/produtos"

    expect(page).to have_content(visible.name)
    expect(page).not_to have_content("Inactive Widget")
    expect(page).not_to have_content("Other Shop Widget")
  end

  it "shows the product detail page" do
    shop = create(:shop)
    product = ActsAsTenant.with_tenant(shop) { create(:product, shop: shop, description: "Full description here.") }

    visit "/#{shop.slug}/produtos/#{product.id}"

    expect(page).to have_content(product.name)
    expect(page).to have_content("Full description here.")
  end
end
