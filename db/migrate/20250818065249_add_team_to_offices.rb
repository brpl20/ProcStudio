class AddTeamToOffices < ActiveRecord::Migration[7.0]
  def up
    # Buscar team padrão
    default_team = Team.find_by(subdomain: 'default')

    # Adicionar coluna sem constraint NOT NULL
    add_reference :offices, :team, null: true, foreign_key: true

    # Atualizar todos os offices existentes para o team padrão
    Office.update_all(team_id: default_team.id) if default_team

    # Agora adicionar constraint NOT NULL
    change_column_null :offices, :team_id, false
  end

  def down
    remove_reference :offices, :team, foreign_key: true
  end
end
