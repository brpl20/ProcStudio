# frozen_string_literal: true

# == Schema Information
#
# Table name: bank_accounts
#
#  id           :bigint           not null, primary key
#  account      :string
#  agency       :string
#  bank_name    :string
#  operation    :string
#  pix          :string
#  type_account :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class BankAccountSerializer
  include JSONAPI::Serializer

  attributes :id, :bank_name, :type_account, :agency, :account, :operation, :pix
end
