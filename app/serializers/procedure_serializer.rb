# frozen_string_literal: true

# == Schema Information
#
# Table name: procedures
#
#  id               :bigint           not null, primary key
#  ancestry         :string
#  city             :string
#  claim_value      :decimal(15, 2)
#  competence       :string
#  conciliation     :boolean          default(FALSE)
#  conviction_value :decimal(15, 2)
#  deleted_at       :datetime
#  end_date         :date
#  justice_free     :boolean          default(FALSE)
#  notes            :text
#  number           :string
#  priority         :boolean          default(FALSE)
#  priority_type    :string
#  procedure_class  :string
#  procedure_type   :string           not null
#  received_value   :decimal(15, 2)
#  responsible      :string
#  start_date       :date
#  state            :string
#  status           :string           default("in_progress")
#  system           :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  law_area_id      :bigint
#  work_id          :bigint           not null
#
# Indexes
#
#  index_procedures_on_ancestry                    (ancestry)
#  index_procedures_on_competence                  (competence)
#  index_procedures_on_deleted_at                  (deleted_at)
#  index_procedures_on_law_area_id                 (law_area_id)
#  index_procedures_on_number                      (number)
#  index_procedures_on_procedure_type              (procedure_type)
#  index_procedures_on_status                      (status)
#  index_procedures_on_system                      (system)
#  index_procedures_on_work_id                     (work_id)
#  index_procedures_on_work_id_and_procedure_type  (work_id,procedure_type)
#
# Foreign Keys
#
#  fk_rails_...  (law_area_id => law_areas.id)
#  fk_rails_...  (work_id => works.id)
#
class ProcedureSerializer
  include JSONAPI::Serializer

  attributes :procedure_type, :law_area_id, :number, :city, :state, :system, :competence,
             :start_date, :end_date, :procedure_class, :responsible, :claim_value,
             :conviction_value, :received_value, :status, :justice_free, :conciliation,
             :priority, :priority_type, :notes, :parent_id, :work_id, :created_at, :updated_at

  attribute :law_area do |object|
    if object.law_area
      {
        id: object.law_area.id,
        name: object.law_area.name,
        full_name: object.law_area.full_name
      }
    end
  end

  attribute :procedural_parties do |object|
    object.procedural_parties.map do |party|
      {
        id: party.id,
        party_type: party.party_type,
        partyable_type: party.partyable_type,
        partyable_id: party.partyable_id,
        name: party.name,
        cpf_cnpj: party.cpf_cnpj,
        oab_number: party.oab_number,
        is_primary: party.is_primary,
        represented_by: party.represented_by,
        notes: party.notes,
        display_name: party.display_name
      }
    end
  end

  attribute :honoraries do |object|
    object.honoraries.map do |honorary|
      {
        id: honorary.id,
        name: honorary.name,
        description: honorary.description,
        status: honorary.status,
        honorary_type: honorary.honorary_type,
        fixed_honorary_value: honorary.fixed_honorary_value,
        percent_honorary_value: honorary.percent_honorary_value,
        parcelling: honorary.parcelling,
        parcelling_value: honorary.parcelling_value,
        is_global: honorary.is_global?
      }
    end
  end

  attribute :children do |object|
    if object.respond_to?(:children)
      object.children.map do |child|
        {
          id: child.id,
          procedure_type: child.procedure_type,
          number: child.number,
          status: child.status
        }
      end
    else
      []
    end
  end

  attribute :has_children do |object|
    object.has_children?
  end

  attribute :financial_summary do |object|
    object.financial_summary
  end

  attribute :display_name do |object|
    object.display_name
  end

  attribute :location do |object|
    object.location
  end
end
