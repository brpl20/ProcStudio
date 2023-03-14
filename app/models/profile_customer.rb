# frozen_string_literal: true

class ProfileCustomer < ApplicationRecord
  belongs_to :customer

  has_many_attached :files
  validate :file_type

  attr_accessor :flag_access_data, :flag_generate_documents, :flag_signature

  protected

  def file_type
    files.each do |file|
      unless file.content_type.in?('image/jpeg image/png application/pdf')
        errors.add(:files, 'apenas são permtidos nos formatos JPG, PNG ou PDF.')
      end
    end
  end
end
