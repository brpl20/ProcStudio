class MoveFileToOriginal < ActiveRecord::Migration[7.0]
  def up
    Document.find_each do |document|
      if document.file.attached?
        document.original.attach(document.file.blob)
        document.file.purge
      end
    end
  end

  def down
    Document.find_each do |document|
      if document.original.attached?
        document.file.attach(document.original.blob)
        document.original.purge
      end
    end
  end
end
