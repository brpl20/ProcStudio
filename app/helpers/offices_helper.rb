# frozen_string_literal: true

module OfficesHelper
  def options_for_society
    Office.societies.keys.to_a.map { |k| [k, k.humanize] }
  end

  def options_for_office_type
    OfficeType.all
  end

  def options_for_admin
    ProfileAdmin.all
  end
end
