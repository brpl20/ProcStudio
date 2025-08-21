# frozen_string_literal: true

# == Schema Information
#
# Table name: customer_works
#
#  id                  :bigint           not null, primary key
#  deleted_at          :datetime
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  profile_customer_id :bigint           not null
#  work_id             :bigint           not null
#
# Indexes
#
#  index_customer_works_on_deleted_at           (deleted_at)
#  index_customer_works_on_profile_customer_id  (profile_customer_id)
#  index_customer_works_on_work_id              (work_id)
#
# Foreign Keys
#
#  fk_rails_...  (profile_customer_id => profile_customers.id)
#  fk_rails_...  (work_id => works.id)
#
class CustomerWorkSerializer
  include JSONAPI::Serializer

  attributes :procedure, :law_area_id, :number, :other_description, :physical_lawyer, :responsible_lawyer,
             :partner_lawyer, :intern, :bachelor, :initial_atendee, :note, :folder, :rate_parceled_exfield,
             :extra_pending_document, :compensations_five_years, :compensations_service, :lawsuit,
             :gain_projection, :procedures, :honorary, :status

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

  attribute :profile_customers do |_, params|
    profile_customer = params[:current_user].profile_customer
    {
      id: profile_customer.id,
      name: profile_customer.name,
      email: profile_customer.customer.email,
      represent: {
        id: profile_customer&.represent&.id,
        representor_id: profile_customer&.represent&.representor_id,
        representor_name: profile_customer&.represent&.representor&.full_name
      }
    }
  end

  attribute :user_profiles do |object|
    object.user_profiles.map do |profile|
      {
        id: profile.id,
        name: profile.name,
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
        description: document.description
      }
    end
  end

  attribute :documents do |object|
    DocumentSerializer.simple_serialize(object.documents)
  end

  attribute :initial_atendee do |object|
    return {} unless object.initial_atendee

    atendee = UserProfile.find(object.initial_atendee)
    {
      id: atendee.id,
      full_name: atendee.full_name
    }
  rescue ActiveRecord::RecordNotFound
    {}
  end

  attribute :responsible_lawyer do |object|
    return {} unless object.responsible_lawyer

    lawyer = UserProfile.find(object.responsible_lawyer)
    {
      id: lawyer.id,
      full_name: lawyer.full_name
    }
  rescue ActiveRecord::RecordNotFound
    {}
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

  attribute :created_at_date do |object|
    object.created_at.to_date.iso8601
  end
end
