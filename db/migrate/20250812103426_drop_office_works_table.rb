class DropOfficeWorksTable < ActiveRecord::Migration[7.0]
  def up
    # Drop foreign key constraints first
    remove_foreign_key :office_works, :works if foreign_key_exists?(:office_works, :works)
    remove_foreign_key :office_works, :offices if foreign_key_exists?(:office_works, :offices)
    
    # Drop the table
    drop_table :office_works
  end
  
  def down
    # Recreate table structure if rollback is needed
    create_table :office_works do |t|
      t.bigint "work_id", null: false
      t.bigint "office_id", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.datetime "deleted_at"
    end
    
    add_index :office_works, ["deleted_at"], name: "index_office_works_on_deleted_at"
    add_index :office_works, ["office_id"], name: "index_office_works_on_office_id"
    add_index :office_works, ["work_id"], name: "index_office_works_on_work_id"
    
    add_foreign_key :office_works, :offices
    add_foreign_key :office_works, :works
  end
end
