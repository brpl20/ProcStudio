class UpdateCreatedByReferences < ActiveRecord::Migration[6.1]
  def change
    # Remover referências se existirem
    remove_reference_if_exists :jobs, :created_by, foreign_key: { to_table: :admins }
    remove_reference_if_exists :customers, :created_by, foreign_key: { to_table: :admins }
    remove_reference_if_exists :works, :created_by, foreign_key: { to_table: :admins }
    remove_reference_if_exists :profile_customers, :created_by, foreign_key: { to_table: :admins }

    # Adicionar colunas se não existirem
    add_column_if_not_exists :jobs, :created_by_id, :bigint
    add_column_if_not_exists :customers, :created_by_id, :bigint
    add_column_if_not_exists :works, :created_by_id, :bigint
    add_column_if_not_exists :profile_customers, :created_by_id, :bigint
  end

  private

  # Método para verificar e remover referência
  def remove_reference_if_exists(table, column, **options)
    if column_exists?(table, column)
      remove_reference table, column, **options
    end
  end

  # Método para verificar e adicionar coluna
  def add_column_if_not_exists(table, column, type, **options)
    unless column_exists?(table, column)
      add_column table, column, type, **options
    end
  end
end
