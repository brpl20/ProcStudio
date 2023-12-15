# frozen_string_literal: true

# == Schema Information
#
# Table name: offices
#
#  id             :bigint(8)        not null, primary key
#  name           :string
#  cnpj           :string
#  oab            :string
#  society        :string
#  foundation     :date
#  site           :string
#  cep            :string
#  street         :string
#  number         :integer
#  neighborhood   :string
#  city           :string
#  state          :string
#  office_type_id :bigint(8)        not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class Office < ApplicationRecord
  belongs_to :office_type
  has_many :profile_admins
  has_one_attached :logo

  enum society: {
    sole_proprietorship: 'sole_proprietorship',
    company: 'company',
    individual: 'individual'
  }
  has_many :office_phones, dependent: :destroy
  has_many :phones, through: :office_phones

  has_many :office_emails, dependent: :destroy
  has_many :emails, through: :office_emails

  has_many :office_bank_accounts, dependent: :destroy
  has_many :bank_accounts, through: :office_bank_accounts

  has_many :office_works, dependent: :destroy
  has_many :works, through: :office_works

  accepts_nested_attributes_for :phones, :emails, :bank_accounts, reject_if: :all_blank
end
