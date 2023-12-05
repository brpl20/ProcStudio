# frozen_string_literal: true

class WorkSerializer
  include JSONAPI::Serializer
  attributes :procedure, :subject, :number, :civel_area, :social_security_areas, :laborite_areas,
             :other_description, :laborite_areas, :tributary_areas, :physical_lawyer, :responsible_lawyer,
             :partner_lawyer, :intern, :bachelor, :initial_atendee, :note, :folder, :rate_parceled_exfield,
             :extra_pending_document, :compensations_five_years, :compensations_service, :lawsuit,
             :gain_projection, :physical_lawyer

  attribute :procurations_created do |object|
    object.documents.procurations.size
  end
end
