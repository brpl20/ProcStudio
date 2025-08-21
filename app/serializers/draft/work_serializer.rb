# frozen_string_literal: true

# == Schema Information
#
# Table name: draft_works
#
#  id         :bigint           not null, primary key
#  deleted_at :datetime
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  work_id    :bigint           not null
#
# Indexes
#
#  index_draft_works_on_deleted_at  (deleted_at)
#  index_draft_works_on_work_id     (work_id)
#
# Foreign Keys
#
#  fk_rails_...  (work_id => works.id)
#
class Draft::WorkSerializer
  include JSONAPI::Serializer

  attributes :name, :work_id

  attributes :procedure, :law_area_id, :number, :other_description, :physical_lawyer,
             :responsible_lawyer, :partner_lawyer, :intern, :bachelor, :initial_atendee,
             :note, :folder, :rate_parceled_exfield, :extra_pending_document,
             :compensations_five_years, :compensations_service, :lawsuit, :gain_projection,
             :procedures, :offices, :honorary, :profile_customers, :user_profiles,
             :powers, :recommendations, :jobs, :pending_documents, :documents, :law_area,
             if: proc { |_, options| options[:action] == 'show' }

  attribute :honorary do |object|
    honorary = object.honorary

    next if honorary.blank?

    {
      fixed_honorary_value: honorary&.fixed_honorary_value,
      parcelling_value: honorary&.parcelling_value,
      honorary_type: honorary&.honorary_type,
      percent_honorary_value: honorary&.percent_honorary_value,
      parcelling: honorary&.parcelling
    }
  end

  attribute :offices do |object|
    object.offices.map do |office|
      {
        id: office.id,
        name: office.name
      }
    end
  end

  attribute :profile_customers do |object|
    object.profile_customers.map do |profile|
      {
        id: profile.id,
        name: profile.full_name,
        email: profile.customer.email
      }
    end
  end

  attribute :user_profiles do |object|
    object.user_profiles.map do |profile|
      {
        id: profile.id,
        name: profile.full_name,
        email: profile.user.email,
        role: profile.role
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
        commission: recommendation.commission,
        percentage: recommendation.percentage,
        profile_customer_id: recommendation.profile_customer_id
      }
    end
  end

  attribute :jobs do |object|
    object.jobs.map do |job|
      {
        description: job.description,
        deadline: job.deadline,
        status: job.status,
        priority: job.priority,
        comment: job.comment,
        profile_admin_id: job.profile_admin_id,
        profile_customer_id: job.profile_customer_id
      }
    end
  end

  attribute :pending_documents do |object|
    object.pending_documents.map do |document|
      {
        description: document.description
      }
    end
  end

  attribute :documents do |object|
    object.documents.map do |document|
      {
        document_type: document.document_type
      }
    end
  end

  attribute :law_area do |object|
    if object.law_area
      {
        id: object.law_area.id,
        name: object.law_area.name,
        full_name: object.law_area.full_name,
        code: object.law_area.code,
        parent_area_id: object.law_area.parent_area_id
      }
    end
  end

  attribute :deleted do |object|
    object.deleted_at.present?
  end
end
