class Cart < ApplicationRecord
  acts_as_tenant(:shop)

  belongs_to :user, optional: true
  has_many :cart_items, dependent: :destroy

  def total_cents
    cart_items.sum { |item| item.quantity * item.unit_price_cents }
  end
end
