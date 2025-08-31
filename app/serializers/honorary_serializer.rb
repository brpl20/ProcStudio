# frozen_string_literal: true

class HonorarySerializer
  include JSONAPI::Serializer

  attributes :id, :name, :description, :fixed_honorary_value,
             :percent_honorary_value, :parcelling, :parcelling_value,
             :work_prev, :honorary_type, :status,
             :created_at, :updated_at

  attribute :is_global, &:is_global?

  attribute :is_procedure_specific, &:is_procedure_specific?

  attribute :total_estimated_value, &:total_estimated_value

  belongs_to :work, if: proc { |record| record.work.present? }
  belongs_to :procedure, if: proc { |record| record.procedure.present? }

  has_many :components, serializer: :honorary_component
  has_one :legal_cost
end
