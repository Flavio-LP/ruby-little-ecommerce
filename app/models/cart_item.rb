class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  validates :quantity, numericality: { greater_than: 0 }
  validates :unit_price_cents, presence: true

  def subtotal_cents
    quantity * unit_price_cents
  end
end
