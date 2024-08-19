# frozen_string_literal: true

# == Schema Information
#
# Table name: admin_addresses
#
#  id               :bigint(8)        not null, primary key
#  address_id       :bigint(8)        not null
#  profile_admin_id :bigint(8)        not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  deleted_at       :datetime
#
class AdminAddress < ApplicationRecord
  acts_as_paranoid

  belongs_to :address
  belongs_to :profile_admin
end
