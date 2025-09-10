# frozen_string_literal: true

# == Schema Information
#
# Table name: user_profile_works
#
#  id              :bigint           not null, primary key
#  deleted_at      :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  user_profile_id :bigint           not null
#  work_id         :bigint           not null
#
# Indexes
#
#  index_user_profile_works_on_deleted_at       (deleted_at)
#  index_user_profile_works_on_user_profile_id  (user_profile_id)
#  index_user_profile_works_on_work_id          (work_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_profile_id => user_profiles.id)
#  fk_rails_...  (work_id => works.id)
#

class UserProfileWork < ApplicationRecord
  acts_as_paranoid

  belongs_to :user_profile
  belongs_to :work
end
