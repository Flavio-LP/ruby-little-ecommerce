require 'rails_helper'

RSpec.describe User, type: :model do
  it "is valid with a valid role" do
    user = build(:user, role: :seller)
    expect(user).to be_valid
  end

  it "defaults to the customer role" do
    user = build(:user)
    expect(user.role).to eq("customer")
  end

  it "is not valid without a role" do
    user = build(:user)
    user.role = nil
    expect(user).not_to be_valid
  end
end
