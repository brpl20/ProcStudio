# frozen_string_literal: true

class CustomerWorkSerializer
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

  attribute :documents do |object, params|
    object.documents.select { _1.profile_customer == params[:current_user].profile_customer }.map do |document|
      {
        id: document.id,
        document_type: document.document_type,
        work_id: document.work_id,
        profile_customer_id: document.profile_customer_id,
        created_at: document.created_at,
        updated_at: document.updated_at,
        url: document.document_docx&.url
      }
    end
  end

  attribute :initial_atendee do |object|
    atendee = ProfileAdmin.find(object.initial_atendee)

    {
      id: atendee.id,
      full_name: atendee.full_name
    }
  rescue ActiveRecord::RecordNotFound
    {}
  end

  attribute :responsible_lawyer do |object|
    lawyer = ProfileAdmin.find(object.responsible_lawyer)

    {
      id: lawyer.id,
      full_name: lawyer.full_name
    }
  rescue ActiveRecord::RecordNotFound
    {}
  end
end
