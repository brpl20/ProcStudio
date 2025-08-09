class AddTeamIdToCustomers < ActiveRecord::Migration[7.0]
  def change
    add_reference :customers, :team, null: true, foreign_key: true
    
    # Depois podemos definir um team padrão para dados existentes se necessário
    # Team.find_or_create_by(name: 'Default Team', subdomain: 'default') se não houver teams
  end
end
