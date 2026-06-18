require "rails_helper"

RSpec.describe "Seller product management", type: :feature do
  it "lets a seller create a product and see it in the index" do
    shop = create(:shop)
    seller = create(:user, :seller, shop: shop)
    sign_in seller

    visit new_admin_product_path(shop_slug: shop.slug)

    fill_in "Name", with: "Widget"
    fill_in "Description", with: "A fine widget."
    fill_in "Price (cents)", with: "1500"
    fill_in "Sku", with: "WID-1"
    click_button "Create Product"

    expect(page).to have_current_path(admin_products_path(shop_slug: shop.slug))
    expect(page).to have_content("Widget")
  end
end
