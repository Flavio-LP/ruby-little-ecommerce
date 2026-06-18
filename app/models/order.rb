class Order < ApplicationRecord
  acts_as_tenant(:shop)

  belongs_to :user, optional: true
  has_many :line_items, dependent: :destroy

  enum :status, { pending: 0, paid: 1, fulfilled: 2, cancelled: 3 }

  validates :total_cents, presence: true
end
