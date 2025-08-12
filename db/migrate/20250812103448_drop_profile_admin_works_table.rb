class DropProfileAdminWorksTable < ActiveRecord::Migration[7.0]
  def up
    # Drop foreign key constraints first
    remove_foreign_key :profile_admin_works, :profile_admins if foreign_key_exists?(:profile_admin_works, :profile_admins)
    remove_foreign_key :profile_admin_works, :works if foreign_key_exists?(:profile_admin_works, :works)
    
    # Drop the table
    drop_table :profile_admin_works
  end
  
  def down
    # Recreate table structure if rollback is needed
    create_table :profile_admin_works do |t|
      t.bigint "profile_admin_id", null: false
      t.bigint "work_id", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.datetime "deleted_at"
    end
    
    add_index :profile_admin_works, ["deleted_at"], name: "index_profile_admin_works_on_deleted_at"
    add_index :profile_admin_works, ["profile_admin_id"], name: "index_profile_admin_works_on_profile_admin_id"
    add_index :profile_admin_works, ["work_id"], name: "index_profile_admin_works_on_work_id"
    
    add_foreign_key :profile_admin_works, :profile_admins
    add_foreign_key :profile_admin_works, :works
  end
end
