class Shop < ApplicationRecord
  has_one :owner, class_name: "User", foreign_key: "shop_id", dependent: :nullify, inverse_of: :shop
  has_many :products, dependent: :destroy
  has_many :carts, dependent: :destroy
  has_many :orders, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-z0-9-]+\z/ }
end
