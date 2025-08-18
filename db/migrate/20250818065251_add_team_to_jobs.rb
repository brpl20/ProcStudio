# frozen_string_literal: true

class AddTeamToJobs < ActiveRecord::Migration[7.0]
  def up
    # Buscar team padrão
    default_team = Team.find_by(subdomain: 'default')

    # Adicionar coluna sem constraint NOT NULL
    add_reference :jobs, :team, null: true, foreign_key: true

    # Atualizar todos os jobs existentes para o team padrão
    Job.update_all(team_id: default_team.id) if default_team

    # Agora adicionar constraint NOT NULL
    change_column_null :jobs, :team_id, false
  end

  def down
    remove_reference :jobs, :team, foreign_key: true
  end
end
