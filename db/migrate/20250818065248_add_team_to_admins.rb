class AddTeamToAdmins < ActiveRecord::Migration[7.0]
  def up
    # Primeiro criar team padrão
    default_team = Team.create!(
      name: 'Escritório Principal',
      subdomain: 'default'
    )

    # Adicionar coluna sem constraint NOT NULL
    add_reference :admins, :team, null: true, foreign_key: true

    # Atualizar todos os admins existentes para o team padrão
    Admin.update_all(team_id: default_team.id)

    # Agora adicionar constraint NOT NULL
    change_column_null :admins, :team_id, false
  end

  def down
    remove_reference :admins, :team, foreign_key: true
  end
end
