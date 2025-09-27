# frozen_string_literal: true

# == Schema Information
#
# Table name: customer_files
#
#  id                  :bigint           not null, primary key
#  deleted_at          :datetime
#  file_description    :string
#  file_s3_key         :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  profile_customer_id :bigint           not null
#
# Indexes
#
#  index_customer_files_on_deleted_at           (deleted_at)
#  index_customer_files_on_profile_customer_id  (profile_customer_id)
#
# Foreign Keys
#
#  fk_rails_...  (profile_customer_id => profile_customers.id)
#

class CustomerFile < ApplicationRecord
  include S3PathBuilder

  acts_as_paranoid

  belongs_to :profile_customer
  has_one_attached :file

  enum :file_description, {
    simple_procuration: 'simple procuration', # procuracao simples
    rg: 'rg',
    cpf: 'cpf',
    proof_of_address: 'proof of address' # comprovante de endereco
  }

  scope :simple_procuration, -> { where(file_description: 'simple_procuration') }
end
