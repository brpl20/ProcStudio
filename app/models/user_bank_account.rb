# frozen_string_literal: true

# == Schema Information
#
# Table name: user_bank_accounts
#
#  id              :bigint           not null, primary key
#  deleted_at      :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  bank_account_id :bigint           not null
#  user_profile_id :bigint           not null
#
# Indexes
#
#  index_user_bank_accounts_on_bank_account_id  (bank_account_id)
#  index_user_bank_accounts_on_deleted_at       (deleted_at)
#  index_user_bank_accounts_on_user_profile_id  (user_profile_id)
#
# Foreign Keys
#
#  fk_rails_...  (bank_account_id => bank_accounts.id)
#  fk_rails_...  (user_profile_id => user_profiles.id)
#

class UserBankAccount < ApplicationRecord
  acts_as_paranoid

  belongs_to :bank_account
  belongs_to :user_profile
end
