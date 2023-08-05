# frozen_string_literal: true

class WorkSerializer
  include JSONAPI::Serializer
  attributes :procedure, :subject, :number, :civel_area, :social_security_areas, :laborite_areas, :other_description, :laborite_areas, :tributary_areas


  # se faz necessario criarmos a estrutura completa do json para podermos criar um teste adequado.
  # attributes :profile_customers, :folder, :initial_atendee, :note, :extra_pending_document, :powers, :jobs, :offices, if: proc { |_, options| options[:action] == 'show' }
end
