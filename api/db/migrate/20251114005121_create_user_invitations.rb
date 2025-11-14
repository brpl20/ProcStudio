class CreateUserInvitations < ActiveRecord::Migration[8.0]
  def change
    create_table :user_invitations do |t|
      t.string :email, null: false
      t.string :token, null: false
      t.bigint :invited_by_id, null: false
      t.bigint :team_id, null: false
      t.string :status, null: false, default: 'pending'
      t.datetime :expires_at, null: false
      t.datetime :accepted_at
      t.jsonb :metadata, default: {}
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :user_invitations, :token, unique: true
    add_index :user_invitations, :email
    add_index :user_invitations, :invited_by_id
    add_index :user_invitations, :team_id
    add_index :user_invitations, :status
    add_index :user_invitations, :deleted_at
    add_index :user_invitations, [:email, :team_id, :status]

    add_foreign_key :user_invitations, :users, column: :invited_by_id
    add_foreign_key :user_invitations, :teams
  end
end
