# frozen_string_literal: true

module Represents
  class SerializerService
    def self.call(represent, detailed: false)
      new.call(represent, detailed: detailed)
    end

    def call(represent, detailed: false)
      data = basic_representation_data(represent)
      data.merge!(detailed_representation_data(represent)) if detailed
      data
    end

    private

    def basic_representation_data(represent)
      {
        id: represent.id,
        profile_customer_id: represent.profile_customer_id,
        profile_customer_name: represent.profile_customer&.full_name,
        profile_customer_cpf: represent.profile_customer&.cpf,
        profile_customer_capacity: represent.profile_customer&.capacity,
        representor_id: represent.representor_id,
        representor_name: represent.representor&.full_name,
        representor_cpf: represent.representor&.cpf,
        relationship_type: represent.relationship_type,
        active: represent.active,
        start_date: represent.start_date,
        end_date: represent.end_date,
        created_at: represent.created_at,
        updated_at: represent.updated_at
      }
    end

    def detailed_representation_data(represent)
      {
        notes: represent.notes,
        team_id: represent.team_id,
        profile_customer: profile_customer_data(represent),
        representor: representor_data(represent)
      }
    end

    def profile_customer_data(represent)
      {
        id: represent.profile_customer&.id,
        name: represent.profile_customer&.full_name,
        cpf: represent.profile_customer&.cpf,
        capacity: represent.profile_customer&.capacity,
        birth: represent.profile_customer&.birth,
        email: represent.profile_customer&.customer&.email
      }
    end

    def representor_data(represent)
      {
        id: represent.representor&.id,
        name: represent.representor&.full_name,
        cpf: represent.representor&.cpf,
        profession: represent.representor&.profession,
        email: represent.representor&.customer&.email,
        phone: represent.representor&.last_phone
      }
    end
  end
end
