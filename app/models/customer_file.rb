# frozen_string_literal: true

# == Schema Information
#
# Table name: customer_files
#
#  id                  :bigint(8)        not null, primary key
#  file_description    :string
#  profile_customer_id :bigint(8)        not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  deleted_at          :datetime
#
class CustomerFile < ApplicationRecord
  acts_as_paranoid

  belongs_to :profile_customer
  has_one_attached :file

  enum file_description: {
    simple_procuration: 'simple procuration', # procuracao simples
    rg: 'rg',
    cpf: 'cpf',
    proof_of_address: 'proof of address' # comprovante de endereco
  }

  scope :simple_procuration, -> { where(file_description: 'simple_procuration') }
end
