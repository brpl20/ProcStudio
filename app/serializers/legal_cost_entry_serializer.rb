# frozen_string_literal: true

class LegalCostEntrySerializer
  include JSONAPI::Serializer

  attributes :id, :name, :description, :amount, :estimated,
             :paid, :due_date, :payment_date, :receipt_number,
             :payment_method, :metadata, :created_at, :updated_at

  attribute :cost_type_key, &:cost_type_key

  attribute :display_name, &:display_name

  attribute :status, &:status

  attribute :status_color, &:status_color

  attribute :overdue, &:overdue?

  attribute :days_until_due, &:days_until_due

  attribute :days_overdue, &:days_overdue

  belongs_to :legal_cost
  belongs_to :legal_cost_type
end
