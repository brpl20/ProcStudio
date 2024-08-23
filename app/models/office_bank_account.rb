# frozen_string_literal: true

# == Schema Information
#
# Table name: office_bank_accounts
#
#  id              :bigint(8)        not null, primary key
#  bank_account_id :bigint(8)        not null
#  office_id       :bigint(8)        not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  deleted_at      :datetime
#
class OfficeBankAccount < ApplicationRecord
  acts_as_paranoid

  belongs_to :bank_account
  belongs_to :office
end
