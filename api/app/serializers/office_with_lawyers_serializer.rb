# frozen_string_literal: true

class OfficeWithLawyersSerializer
  include JSONAPI::Serializer

  attributes :name, :quote_value, :number_of_quotes, :total_quotes_value

  attribute :lawyers do |object|
    # Get users with OAB (lawyers) associated with this office
    lawyers = object.users.where.not(oab: [nil, ''])
    lawyers.map do |lawyer|
      user_office = object.user_offices.find_by(user: lawyer)
      profile = lawyer.user_profile
      {
        id: lawyer.id,
        user_office_id: user_office&.id,
        email: lawyer.email,
        oab: lawyer.oab,
        name: profile&.name || lawyer.email.split('@').first,
        partnership_type: user_office&.partnership_type,
        partnership_percentage: user_office&.partnership_percentage
      }
    end
  end
end
