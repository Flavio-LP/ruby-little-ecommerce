class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, { seller: 0, customer: 1 }

  belongs_to :shop, optional: true

  # Virtual attribute, only used to carry the shop name through the
  # registration form into Shops::Register — never persisted on User.
  attr_accessor :shop_name

  validates :role, presence: true
end
