# frozen_string_literal: true

class WorkSerializer
  include JSONAPI::Serializer
  attributes :procedure, :subject, :number,
             :folder, :initial_atendee, :note, :extra_pending_document

  has_many :profile_customers, serializer: ProfileCustomerSerializer
  has_many :powers, serializer: PowerSerializer
  has_many :jobs, serializer: JobSerializer
  has_many :offices, serializer: OfficeSerializer
end
