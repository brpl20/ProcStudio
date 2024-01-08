class Draft::WorkSerializer
  attributes :procedure, :subject, :number, :civel_area, :social_security_areas,
             :other_description, :laborite_areas, :tributary_areas, :physical_lawyer, :responsible_lawyer,
             :partner_lawyer, :intern, :bachelor, :initial_atendee, :note, :folder, :rate_parceled_exfield,
             :extra_pending_document, :compensations_five_years, :compensations_service, :lawsuit,
             :gain_projection, :procedures, :office_ids, :profile_customer_ids, :profile_admin_ids

  attribute :honorary do |object|
    {
      fixed_honorary_value: object.honorary.fixed_honorary_value,
      parcelling_value: object.honorary.parcelling_value,
      honorary_type: object.honorary.honorary_type,
      percent_honorary_value: object.honorary.percent_honorary_value,
      parcelling: object.honorary.parcelling
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

  attribute :profile_admins do |object|
    object.profile_admins.map do |profile|
      {
        id: profile.id,
        name: profile.full_name,
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
        commission: recommendation.commission,
        percentage: recommendation.percentage,
        profile_customer_id: recommendation.profile_customer_id
      }
    end
  end

  attribute :jobs do |object|
    object.jobs.map do |job|
      {
        description: job.description
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
end
