# frozen_string_literal: true

class JobSerializer
  include JSONAPI::Serializer
  attributes :description, :deadline, :status, :priority, :comment

  attribute :customer do |object|
    "#{object.profile_customer.name} #{object.profile_customer.last_name}"
  end

  attribute :responsible do |object|
    object.profile_admin.name
  end

  attribute :work_number do |object|
    object.work.number if object.work.present?
  end

  attributes :profile_admin_id, if: proc { |_, options| options[:action] == 'show' }

  attribute :profile_customer, if: proc { |_, options| options[:action] == 'show' } do |object|
    {
      id: object.profile_customer.id,
      customer_type: object.profile_customer.customer_type,
      name: object.profile_customer.name,
      last_name: object.profile_customer.last_name,
      gender: object.profile_customer.gender,
      rg: object.profile_customer.rg,
      cpf: object.profile_customer.cpf,
      cnpj: object.profile_customer.cnpj,
      nationality: object.profile_customer.nationality,
      civil_status: object.profile_customer.civil_status,
      capacity: object.profile_customer.capacity,
      profession: object.profile_customer.profession,
      company: object.profile_customer.company,
      birth: object.profile_customer.birth.to_json,
      mother_name: object.profile_customer.mother_name,
      number_benefit: object.profile_customer.number_benefit,
      status: object.profile_customer.status,
      document: object.profile_customer.document,
      nit: object.profile_customer.nit,
      inss_password: object.profile_customer.inss_password,
      invalid_person: object.profile_customer.invalid_person,
      customer_id: object.profile_customer.customer_id
    }
  end

  attributes :work, if: proc { |_, options| options[:action] == 'show' } do |object|
    {
      id: object.work.id,
      procedure: object.work.procedure,
      subject: object.work.subject,
      number: object.work.number,
      rate_parceled_exfield: object.work.rate_parceled_exfield,
      folder: object.work.folder,
      initial_atendee: object.work.initial_atendee,
      note: object.work.note,
      extra_pending_document: object.work.extra_pending_document,
      created_at: object.work.created_at.iso8601,
      updated_at: object.work.updated_at.iso8601,
      civel_area: object.work.civel_area,
      social_security_areas: object.work.social_security_areas,
      laborite_areas: object.work.laborite_areas,
      tributary_areas: object.work.tributary_areas,
      other_description: object.work.other_description,
      compensations_five_years: object.work.compensations_five_years,
      compensations_service: object.work.compensations_service,
      lawsuit: object.work.lawsuit,
      gain_projection: object.work.gain_projection
    }
  end
end
