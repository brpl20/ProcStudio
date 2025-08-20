# frozen_string_literal: true

# == Schema Information
#
# Table name: user_addresses
#
#  id              :bigint           not null, primary key
#  deleted_at      :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  address_id      :bigint           not null
#  user_profile_id :bigint           not null
#
# Indexes
#
#  index_user_addresses_on_address_id       (address_id)
#  index_user_addresses_on_deleted_at       (deleted_at)
#  index_user_addresses_on_user_profile_id  (user_profile_id)
#
# Foreign Keys
#
#  fk_rails_...  (address_id => addresses.id)
#  fk_rails_...  (user_profile_id => user_profiles.id)
#

class UserAddress < ApplicationRecord
  acts_as_paranoid

  belongs_to :address
  belongs_to :user_profile
end
