# frozen_string_literal: true

# == Schema Information
#
# Table name: payment_transactions
#
#  id              :bigint(8)        not null, primary key
#  subscription_id :bigint(8)        not null
#  amount          :decimal(10, 2)   not null
#  currency        :string           default("BRL")
#  status          :string           default("pending")
#  payment_method  :string
#  transaction_id  :string
#  payment_data    :json
#  processed_at    :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class PaymentTransaction < ApplicationRecord
  belongs_to :subscription
  
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :currency, inclusion: { in: %w[BRL USD EUR] }
  validates :status, inclusion: { 
    in: %w[pending processing completed failed cancelled refunded] 
  }
  validates :transaction_id, uniqueness: true, allow_blank: true
  
  scope :completed, -> { where(status: 'completed') }
  scope :pending, -> { where(status: 'pending') }
  scope :failed, -> { where(status: 'failed') }
  scope :by_payment_method, ->(method) { where(payment_method: method) }
  
  def pending?
    status == 'pending'
  end
  
  def processing?
    status == 'processing'
  end
  
  def completed?
    status == 'completed'
  end
  
  def failed?
    status == 'failed'
  end
  
  def cancelled?
    status == 'cancelled'
  end
  
  def refunded?
    status == 'refunded'
  end
  
  def display_amount
    case currency
    when 'BRL'
      "R$ #{format('%.2f', amount)}"
    when 'USD'
      "$ #{format('%.2f', amount)}"
    when 'EUR'
      "€ #{format('%.2f', amount)}"
    else
      "#{currency} #{format('%.2f', amount)}"
    end
  end
  
  def payment_gateway
    payment_data['gateway'] || payment_method
  end
  
  def gateway_transaction_id
    payment_data['gateway_transaction_id'] || transaction_id
  end
end
