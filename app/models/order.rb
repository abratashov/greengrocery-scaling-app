class Order < ApplicationRecord
  acts_as_tenant(:tenant)

  ORDER_STATES = {
    pending: 'pending',
    in_progress: 'in_progress',
    created: 'created',
    done: 'done',
    sent: 'sent',
    delivered: 'delivered',
    cancelled: 'cancelled',
    failed: 'failed'
  }.freeze

  enum :state, ORDER_STATES

  belongs_to :tenant
  belongs_to :user
  has_many :product_orders, dependent: :destroy
  has_one :payment, dependent: :destroy

  validates :tenant, presence: true
  validates :user, presence: true
  # validates :state, inclusion: { in: ORDER_STATES.values }
end
