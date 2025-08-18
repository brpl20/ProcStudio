class AddTeamToWorks < ActiveRecord::Migration[7.0]
  def up
    # Buscar team padrão
    default_team = Team.find_by(subdomain: 'default')

    # Adicionar coluna sem constraint NOT NULL
    add_reference :works, :team, null: true, foreign_key: true

    # Atualizar todos os works existentes para o team padrão
    Work.update_all(team_id: default_team.id) if default_team

    # Agora adicionar constraint NOT NULL
    change_column_null :works, :team_id, false
  end

  def down
    remove_reference :works, :team, foreign_key: true
  end
end
