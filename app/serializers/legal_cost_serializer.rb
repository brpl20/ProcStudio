# frozen_string_literal: true

class LegalCostSerializer
  include JSONAPI::Serializer

  attributes :id, :client_responsible, :include_in_invoices,
             :admin_fee_percentage, :created_at, :updated_at

  attribute :total_amount, &:total_amount

  attribute :paid_amount, &:paid_amount

  attribute :pending_amount, &:pending_amount

  attribute :estimated_amount, &:estimated_amount

  attribute :confirmed_amount, &:confirmed_amount

  attribute :admin_fee_amount, &:admin_fee_amount

  attribute :total_with_admin_fee, &:total_with_admin_fee

  attribute :honorary_id, &:honorary_id

  # Relationships (commented out to avoid serialization issues in controller)
  # belongs_to :honorary
  # has_many :entries, serializer: :legal_cost_entry
end
