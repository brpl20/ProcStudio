class CreateContactInfos < ActiveRecord::Migration[7.0]
  def change
    create_table :contact_infos do |t|
      t.references :contactable, polymorphic: true, null: false
      t.string :contact_type, null: false
      t.json :contact_data, null: false, default: {}
      t.boolean :is_primary, default: false
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :contact_infos, [:contactable_type, :contactable_id]
    add_index :contact_infos, [:contact_type, :contactable_type, :contactable_id], 
              name: 'index_contact_infos_on_type_and_contactable'
    add_index :contact_infos, :deleted_at
    add_index :contact_infos, [:contactable_type, :contactable_id, :is_primary], 
              name: 'index_contact_infos_on_primary'
  end
end
