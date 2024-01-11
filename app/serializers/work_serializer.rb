# frozen_string_literal: true

class WorkSerializer
  include JSONAPI::Serializer

  attributes :procedure, :subject, :number, :civel_area, :social_security_areas,
             :other_description, :laborite_areas, :tributary_areas, :physical_lawyer, :responsible_lawyer,
             :partner_lawyer, :intern, :bachelor, :initial_atendee, :note, :folder, :rate_parceled_exfield,
             :extra_pending_document, :compensations_five_years, :compensations_service, :lawsuit,
             :gain_projection, :procedures, :honorary

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
        description: document.description
      }
    end
  end

  attribute :documents do |object|
    object.documents.map do |document|
      {
        id: document.id,
        document_type: document.document_type,
        work_id: document.work_id,
        created_at: document.created_at,
        updated_at: document.updated_at,
        url: document.document_docx&.url
      }
    end
  end
end
