# frozen_string_literal: true

# == Schema Information
#
# Table name: offices
#
#  id                    :bigint(8)        not null, primary key
#  name                  :string
#  cnpj                  :string
#  oab                   :string
#  society               :string
#  foundation            :date
#  site                  :string
#  cep                   :string
#  street                :string
#  number                :integer
#  neighborhood          :string
#  city                  :string
#  state                 :string
#  office_type_id        :bigint(8)        not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  responsible_lawyer_id :integer
#  accounting_type       :string
#  deleted_at            :datetime
#  team_id               :bigint(8)
#
class Office < ApplicationRecord
  include DeletedFilterConcern

  acts_as_paranoid

  belongs_to :office_type
  belongs_to :responsible_lawyer, class_name: 'ProfileAdmin', optional: true
  belongs_to :team, optional: true

  has_many :profile_admins, dependent: :destroy
  has_one_attached :logo

  enum society: {
    sole_proprietorship: 'sole_proprietorship',
    company: 'company',
    individual: 'individual'
  }

  enum accounting_type: {              # enquadramento contabil
    simple: 'simple',                  # simples
    real_profit: 'real_profit',        # lucro real
    presumed_profit: 'presumed_profit' # lucro presumido
  }

  has_many :office_emails, dependent: :destroy
  has_many :emails, through: :office_emails

  has_many :office_bank_accounts, dependent: :destroy
  has_many :bank_accounts, through: :office_bank_accounts

  has_many :office_works, dependent: :destroy
  has_many :works, through: :office_works

  accepts_nested_attributes_for :emails, :bank_accounts, reject_if: :all_blank

  with_options presence: true do
    validates :name
    validates :cnpj
    validates :city
    validates :cep
    validates :street
    validates :number
    validates :neighborhood
    validates :state
  end
end
