# frozen_string_literal: true

# == Schema Information
#
# Table name: addresses
#
#  id           :bigint(8)        not null, primary key
#  description  :string
#  zip_code     :string
#  street       :string
#  number       :integer
#  neighborhood :string
#  city         :string
#  state        :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class Address < ApplicationRecord
  has_many :admin_addresses, dependent: :destroy
  has_many :profile_admins, through: :admin_addresses

  with_options presence: true do
    validates :zip_code
    validates :street
    validates :city
    validates :state
  end
end
