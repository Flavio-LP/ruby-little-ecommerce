class Product < ApplicationRecord
  acts_as_tenant(:shop)

  validates :name, presence: true
  validates :price_cents, presence: true, numericality: { greater_than: 0 }
end
