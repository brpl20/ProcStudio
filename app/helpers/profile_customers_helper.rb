# frozen_string_literal: true

module ProfileCustomersHelper
  def options_for_gender
    ProfileCustomer.genders.keys.to_a.map { |k| [k, k.humanize] }
  end

  def options_for_civil_status
    ProfileCustomer.civil_statuses.keys.to_a.map { |k| [k, k.humanize] }
  end

  def options_for_nationality
    ProfileCustomer.nationalities.keys.to_a.map { |k| [k, k.humanize] }
  end

  def options_for_capacity
    ProfileCustomer.capacities.keys.to_a.map { |k| [k, k.humanize] }
  end
end
