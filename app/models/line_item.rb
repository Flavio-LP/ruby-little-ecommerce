class LineItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :quantity, numericality: { greater_than: 0 }
  validates :unit_price_cents, presence: true

  def subtotal_cents
    quantity * unit_price_cents
  end
end
