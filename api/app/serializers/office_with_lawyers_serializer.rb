# frozen_string_literal: true

class OfficeWithLawyersSerializer
  include JSONAPI::Serializer

  attributes :name, :quote_value, :number_of_quotes, :total_quotes_value, :proportional

  attribute :lawyers do |object|
    # Get users with OAB (lawyers) associated with this office
    lawyers = object.users.where.not(oab: [nil, ''])
    lawyers.map do |lawyer|
      user_office = object.user_offices.find_by(user: lawyer)
      profile = lawyer.user_profile
      
      # Get compensation data
      compensations = user_office&.compensations&.order(effective_date: :desc) || []
      current_compensation = compensations.first
      
      {
        id: lawyer.id,
        user_office_id: user_office&.id,
        email: lawyer.email,
        oab: lawyer.oab,
        name: profile&.name || lawyer.email.split('@').first,
        partnership_type: user_office&.partnership_type,
        partnership_percentage: user_office&.partnership_percentage,
        is_administrator: user_office&.is_administrator,
        entry_date: user_office&.entry_date,
        current_compensation: current_compensation ? {
          id: current_compensation.id,
          compensation_type: current_compensation.compensation_type,
          amount: current_compensation.amount,
          amount_formatted: MonetaryValidator.format(current_compensation.amount),
          payment_frequency: current_compensation.payment_frequency,
          effective_date: current_compensation.effective_date,
          end_date: current_compensation.end_date,
          notes: current_compensation.notes
        } : nil,
        all_compensations: compensations.map do |comp|
          {
            id: comp.id,
            compensation_type: comp.compensation_type,
            amount: comp.amount,
            amount_formatted: MonetaryValidator.format(comp.amount),
            payment_frequency: comp.payment_frequency,
            effective_date: comp.effective_date,
            end_date: comp.end_date,
            notes: comp.notes
          }
        end
      }
    end
  end
end
