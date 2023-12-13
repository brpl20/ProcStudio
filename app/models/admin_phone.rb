# frozen_string_literal: true

# == Schema Information
#
# Table name: admin_phones
#
#  id               :bigint(8)        not null, primary key
#  phone_id         :bigint(8)        not null
#  profile_admin_id :bigint(8)        not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class AdminPhone < ApplicationRecord
  belongs_to :phone
  belongs_to :profile_admin
end
