module ProfileAdminsHelper

  def options_for_role
    ProfileAdmin.roles.keys.to_a.map { |w| [w.humanize, w] }
  end

  def options_for_gender
    [[0, 'Masculino'], [1, 'Feminino']]
  end

  def options_for_status
    ProfileAdmin.statuses.keys.to_a.map { |w| [w.humanize, w] }
  end
end
