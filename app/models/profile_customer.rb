# frozen_string_literal: true

class ProfileCustomer < ApplicationRecord
  belongs_to :customer

  enum :gender, %i[male female other]
  enum :civil_status, %i[single married divorced widower union]
  enum :nationality, %i[brazilian foreigner]
  enum :capacity, %i[able relatively unable]

  has_many_attached :files

  has_many :customer_addresses, dependent: :destroy
  has_many :addresses, through: :customer_addresses

  has_many :customer_phones, dependent: :destroy
  has_many :phones, through: :customer_phones

  has_many :customer_emails, dependent: :destroy
  has_many :emails, through: :customer_emails

  has_many :customer_bank_accounts, dependent: :destroy
  has_many :bank_accounts, through: :customer_bank_accounts

  attr_accessor :flag_access_data, :flag_generate_documents, :flag_signature

  accepts_nested_attributes_for :customer, :addresses, :phones, :emails, :bank_accounts, reject_if: :all_blank
  validates :name, presence: true


  # validate :file_type

  protected

  def file_type
    files.each do |file|
      unless file.content_type.in?('image/jpeg image/png application/pdf')
        errors.add(:files, 'apenas são permtidos nos formatos JPG, PNG ou PDF.')
      end
    end
  end
end
