class Payment < ApplicationRecord
  PAYMENT_STATES = {
    pending: 'pending',
    in_progress: 'in_progress',
    paid: 'paid',
    failed: 'failed'
  }.freeze

  enum :state, PAYMENT_STATES

  belongs_to :order

  validates :total_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  # validates :state, inclusion: { in: PAYMENT_STATES.values }
end
