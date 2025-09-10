# frozen_string_literal: true

# == Schema Information
#
# Table name: represents
#
#  id                  :bigint           not null, primary key
#  active              :boolean          default(TRUE), not null
#  end_date            :date
#  notes               :text
#  relationship_type   :string           default("representation")
#  start_date          :date
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  profile_customer_id :bigint           not null
#  representor_id      :bigint
#  team_id             :bigint
#
# Indexes
#
#  index_represents_on_active                          (active)
#  index_represents_on_profile_customer_id             (profile_customer_id)
#  index_represents_on_profile_customer_id_and_active  (profile_customer_id,active)
#  index_represents_on_relationship_type               (relationship_type)
#  index_represents_on_representor_id                  (representor_id)
#  index_represents_on_representor_id_and_active       (representor_id,active)
#  index_represents_on_team_id                         (team_id)
#
# Foreign Keys
#
#  fk_rails_...  (profile_customer_id => profile_customers.id)
#  fk_rails_...  (representor_id => profile_customers.id)
#  fk_rails_...  (team_id => teams.id)
#
class RepresentSerializer
  include JSONAPI::Serializer

  attributes :id, :relationship_type, :active, :start_date, :end_date, :notes,
             :created_at, :updated_at

  # Include team information
  attribute :team_id, &:team_id

  # Profile Customer (represented person) information
  attribute :profile_customer do |object|
    if object.profile_customer
      {
        id: object.profile_customer.id,
        name: object.profile_customer.full_name,
        cpf: object.profile_customer.cpf,
        capacity: object.profile_customer.capacity,
        birth: object.profile_customer.birth,
        gender: object.profile_customer.gender,
        civil_status: object.profile_customer.civil_status,
        email: object.profile_customer.customer&.email,
        phone: object.profile_customer.last_phone
      }
    end
  end

  # Representor information
  attribute :representor do |object|
    if object.representor
      {
        id: object.representor.id,
        name: object.representor.full_name,
        cpf: object.representor.cpf,
        rg: object.representor.rg,
        profession: object.representor.profession,
        birth: object.representor.birth,
        gender: object.representor.gender,
        civil_status: object.representor.civil_status,
        email: object.representor.customer&.email,
        phone: object.representor.last_phone,
        address: format_address(object.representor)
      }
    end
  end

  # Relationship status description
  attribute :status_description do |object|
    if object.active?
      if object.end_date.present? && object.end_date < Date.current
        'Expirada'
      elsif object.start_date.present? && object.start_date > Date.current
        'Futura'
      else
        'Ativa'
      end
    else
      'Inativa'
    end
  end

  # Relationship type description in Portuguese
  attribute :relationship_type_label do |object|
    case object.relationship_type
    when 'representation'
      'Representação Legal'
    when 'assistance'
      'Assistência Legal'
    when 'curatorship'
      'Curatela'
    when 'tutorship'
      'Tutela'
    else
      object.relationship_type&.humanize
    end
  end

  # Check if relationship is currently valid
  attribute :is_current do |object|
    object.active? &&
      (object.start_date.nil? || object.start_date <= Date.current) &&
      (object.end_date.nil? || object.end_date >= Date.current)
  end

  # Count of other active representors for the same customer
  attribute :other_active_representors_count do |object|
    object.profile_customer
      .represents
      .active
      .where.not(id: object.id)
      .count
  end

  # List of other active representors (if any)
  attribute :other_active_representors do |object|
    object.profile_customer
      .represents
      .active
      .where.not(id: object.id)
      .includes(:representor)
      .map do |represent|
      {
        id: represent.id,
        representor_name: represent.representor&.full_name,
        representor_cpf: represent.representor&.cpf,
        relationship_type: represent.relationship_type,
        start_date: represent.start_date
      }
    end
  end

  def self.format_address(profile_customer)
    return nil unless profile_customer.addresses.any?

    address = profile_customer.addresses.first
    {
      street: address.street,
      number: address.number,
      neighborhood: address.neighborhood,
      city: address.city,
      state: address.state,
      zip_code: address.zip_code
    }
  end
end
