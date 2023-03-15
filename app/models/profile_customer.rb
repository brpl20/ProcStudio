# frozen_string_literal: true

class ProfileCustomer < ApplicationRecord
  belongs_to :customer

  enum :gender, %i[male female other]
  enum :civil_status, %i[single married divorced widower union]
  enum :nationality, %i[brazilian foreigner]
  enum :capacity, %i[relatively absolutely unable]

  has_many_attached :files

  attr_accessor :flag_access_data, :flag_generate_documents, :flag_signature

  validate :file_type

  protected

  def file_type
    files.each do |file|
      unless file.content_type.in?('image/jpeg image/png application/pdf')
        errors.add(:files, 'apenas são permtidos nos formatos JPG, PNG ou PDF.')
      end
    end
  end
end
