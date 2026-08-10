class Tenant < ApplicationRecord
  DEFAULT_TENANT = "tenant1"

  has_many :users, dependent: :destroy
  has_many :products, dependent: :destroy
  has_many :orders, dependent: :destroy

  validates :name, presence: true, uniqueness: true, format: { with: /\A[a-z0-9\-]+\z/ }
end
