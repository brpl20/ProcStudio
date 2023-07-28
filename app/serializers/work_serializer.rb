# frozen_string_literal: true

class WorkSerializer
  include JSONAPI::Serializer
  attributes :procedure, :subject, :action, :number, :rate_percentage, :rate_percentage_exfield, :rate_fixed,
             :rate_parceled_exfield, :folder, :initial_atendee, :note, :checklist, :extra_pending_document

  has_many :profile_customers, serializer: ProfileCustomerSerializer
  has_many :powers, serializer: PowerSerializer
  has_many :jobs, serializer: JobSerializer
  has_many :offices, serializer: OfficeSerializer
end
