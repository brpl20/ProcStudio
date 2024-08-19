# frozen_string_literal: true

# == Schema Information
#
# Table name: profile_admin_works
#
#  id               :bigint(8)        not null, primary key
#  profile_admin_id :bigint(8)        not null
#  work_id          :bigint(8)        not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  deleted_at       :datetime
#
class ProfileAdminWork < ApplicationRecord
  acts_as_paranoid

  belongs_to :profile_admin
  belongs_to :work
end
