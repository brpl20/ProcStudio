class CreateReferralInvitations < ActiveRecord::Migration[8.0]
  def change
    create_table :referral_invitations do |t|
      t.string :email, null: false
      t.string :token, null: false
      t.bigint :referred_by_id, null: false
      t.bigint :referred_user_id # User created from this referral
      t.string :status, null: false, default: 'pending'
      t.boolean :reward_earned, default: false
      t.datetime :accepted_at
      t.datetime :converted_at
      t.datetime :expires_at, null: false
      t.jsonb :metadata, default: {}
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :referral_invitations, :token, unique: true
    add_index :referral_invitations, :email
    add_index :referral_invitations, :referred_by_id
    add_index :referral_invitations, :referred_user_id
    add_index :referral_invitations, :status
    add_index :referral_invitations, :reward_earned
    add_index :referral_invitations, :deleted_at

    add_foreign_key :referral_invitations, :users, column: :referred_by_id
    add_foreign_key :referral_invitations, :users, column: :referred_user_id
  end
end
