class RenameProjectionColumnFromTributaries < ActiveRecord::Migration[7.0]
  def change
    rename_column :tributaries, :pojection, :projection
  end
end
