require "rails_helper"

RSpec.describe "Seller registration", type: :feature do
  it "creates a shop and redirects to the seller's own admin dashboard" do
    visit new_user_registration_path

    fill_in "Email", with: "newseller@example.com"
    fill_in "Password", with: "password123"
    fill_in "Password confirmation", with: "password123"
    fill_in "Shop name", with: "Acme Store"
    click_button "Sign up"

    shop = Shop.find_by!(slug: "acme-store")

    expect(page).to have_current_path("/acme-store/admin")
    expect(page).to have_content("Acme Store")
    expect(User.find_by(email: "newseller@example.com")).to be_seller
    expect(shop.owner.email).to eq("newseller@example.com")
  end

  it "registers as a plain customer when no shop name is given" do
    visit new_user_registration_path

    fill_in "Email", with: "newcustomer@example.com"
    fill_in "Password", with: "password123"
    fill_in "Password confirmation", with: "password123"
    click_button "Sign up"

    expect(User.find_by(email: "newcustomer@example.com")).to be_customer
  end
end
