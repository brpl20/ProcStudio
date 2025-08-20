# frozen_string_literal: true

# == Schema Information
#
# Table name: phones
#
#  id           :bigint           not null, primary key
#  phone_number :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Phone < ApplicationRecord
  has_many :admin_phones, dependent: :destroy
  has_many :profile_admins, through: :admin_phones

  has_many :office_phones, dependent: :destroy
  has_many :offices, through: :office_phones

  has_many :customer_phones, dependent: :destroy
  has_many :profile_customers, through: :customer_phones
end
