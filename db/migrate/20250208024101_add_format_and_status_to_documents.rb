class AddFormatAndStatusToDocuments < ActiveRecord::Migration[6.0]
  def change
    # Adiciona a coluna format com enum e define o valor padrão como :docx (0)
    add_column :documents, :format, :integer, default: 0, null: false

    # Adiciona a coluna status com enum e define o valor padrão como :waiting_signature (0)
    add_column :documents, :status, :integer, default: 0, null: false
  end
end
