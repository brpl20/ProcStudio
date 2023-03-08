# frozen_string_literal: true

module ProfileAdminsHelper
  def options_for_role
    ProfileAdmin.roles.keys.to_a.map { |k| [k,  ProfileAdmin.human_enum_name(:role, k.to_sym).humanize] }
  end

  def options_for_gender
    [[0, 'Masculino'], [1, 'Feminino']]
  end

  def options_for_status
    ProfileAdmin.statuses.keys.to_a.map { |k| [k, k.humanize] }
  end
end
