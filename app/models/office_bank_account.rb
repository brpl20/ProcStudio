# frozen_string_literal: true

# == Schema Information
#
# Table name: office_bank_accounts
#
#  id              :bigint           not null, primary key
#  deleted_at      :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  bank_account_id :bigint           not null
#  office_id       :bigint           not null
#
# Indexes
#
#  index_office_bank_accounts_on_bank_account_id  (bank_account_id)
#  index_office_bank_accounts_on_deleted_at       (deleted_at)
#  index_office_bank_accounts_on_office_id        (office_id)
#
# Foreign Keys
#
#  fk_rails_...  (bank_account_id => bank_accounts.id)
#  fk_rails_...  (office_id => offices.id)
#

class OfficeBankAccount < ApplicationRecord
  acts_as_paranoid

  belongs_to :bank_account
  belongs_to :office
end
