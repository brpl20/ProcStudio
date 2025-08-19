# frozen_string_literal: true

# == Schema Information
#
# Table name: user_phones
#
#  id              :bigint           not null, primary key
#  deleted_at      :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  phone_id        :bigint           not null
#  user_profile_id :bigint           not null
#
# Indexes
#
#  index_user_phones_on_deleted_at       (deleted_at)
#  index_user_phones_on_phone_id         (phone_id)
#  index_user_phones_on_user_profile_id  (user_profile_id)
#
# Foreign Keys
#
#  fk_rails_...  (phone_id => phones.id)
#  fk_rails_...  (user_profile_id => user_profiles.id)
#

class UserPhone < ApplicationRecord
  acts_as_paranoid

  belongs_to :phone
  belongs_to :user_profile
end
