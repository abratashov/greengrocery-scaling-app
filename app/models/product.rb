class Product < ApplicationRecord
  acts_as_tenant(:tenant)

  belongs_to :tenant
  has_many :product_orders, dependent: :destroy

  validates :tenant, presence: true
  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :amount, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :available, -> { where("amount > 0") }
end
