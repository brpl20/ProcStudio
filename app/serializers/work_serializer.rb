# frozen_string_literal: true

# == Schema Information
#
# Table name: works
#
#  id                                                                   :bigint           not null, primary key
#  bachelor                                                             :integer
#  civel_area(Civil aréas)                                              :string
#  compensations_five_years(Compensações realizadas nos últimos 5 anos) :boolean
#  compensations_service(Compensações de oficio)                        :boolean
#  deleted_at                                                           :datetime
#  extra_pending_document                                               :string
#  folder                                                               :string
#  gain_projection(Projeção de ganho)                                   :string
#  initial_atendee                                                      :integer
#  intern                                                               :integer
#  laborite_areas(Trabalhista aréas)                                    :string
#  lawsuit(Possui ação Judicial)                                        :boolean
#  note                                                                 :string
#  number                                                               :integer
#  other_description(Descrição do outro tipo de assunto)                :text
#  partner_lawyer                                                       :integer
#  physical_lawyer                                                      :integer
#  procedure                                                            :string
#  procedures                                                           :text             default([]), is an Array
#  rate_parceled_exfield                                                :string
#  responsible_lawyer                                                   :integer
#  social_security_areas(Previdênciário aréas)                          :string
#  status                                                               :string           default("in_progress")
#  subject                                                              :string
#  tributary_areas(Tributário aréas)                                    :string
#  created_at                                                           :datetime         not null
#  updated_at                                                           :datetime         not null
#  created_by_id                                                        :bigint
#  team_id                                                              :bigint           not null
#
# Indexes
#
#  index_works_on_created_by_id  (created_by_id)
#  index_works_on_deleted_at     (deleted_at)
#  index_works_on_team_id        (team_id)
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => users.id)
#  fk_rails_...  (team_id => teams.id)
#
class WorkSerializer
  include JSONAPI::Serializer

  attributes :procedure, :subject, :number, :civel_area, :social_security_areas,
             :other_description, :laborite_areas, :tributary_areas, :physical_lawyer, :responsible_lawyer,
             :partner_lawyer, :intern, :bachelor, :initial_atendee, :note, :folder, :rate_parceled_exfield,
             :extra_pending_document, :compensations_five_years, :compensations_service, :lawsuit,
             :gain_projection, :procedures, :honorary, :created_by_id, :status

  attribute :procurations_created do |object|
    object.documents.procurations.size
  end

  attribute :offices do |object|
    object.offices.map do |office|
      {
        id: office.id,
        name: office.name,
        cnpj: office.cnpj
      }
    end
  end

  attribute :profile_customers do |object|
    object.profile_customers.map do |profile|
      {
        id: profile.id,
        name: profile.name,
        email: profile.customer.email
      }
    end
  end

  attribute :profile_admins do |object|
    object.profile_admins.map do |profile|
      {
        id: profile.id,
        name: profile.name,
        email: profile.admin.email
      }
    end
  end

  attribute :powers do |object|
    object.powers.map do |power|
      {
        id: power.id,
        description: power.description
      }
    end
  end

  attribute :recommendations do |object|
    object.recommendations.map do |recommendation|
      {
        id: recommendation.id,
        commission: recommendation.commission,
        percentage: recommendation.percentage,
        profile_customer_id: recommendation.profile_customer_id
      }
    end
  end

  attribute :jobs do |object|
    object.jobs.map do |job|
      {
        id: job.id,
        description: job.description
      }
    end
  end

  attribute :pending_documents do |object|
    object.pending_documents.map do |document|
      {
        id: document.id,
        description: document.description,
        profile_customer_id: document.profile_customer_id
      }
    end
  end

  attribute :documents do |object|
    DocumentSerializer.simple_serialize(object.documents)
  end

  attribute :work_events do |object|
    object.work_events.order(date: :desc).map do |work_event|
      {
        id: work_event.id,
        description: work_event.description,
        date: work_event.date,
        work_id: work_event.work_id
      }
    end
  end

  attribute :deleted do |object|
    object.deleted_at.present?
  end

  attribute :created_at_date do |object|
    object.created_at.to_date.iso8601
  end
end
