# frozen_string_literal: true

# == Schema Information
#
# Table name: jobs
#
#  id                  :bigint(8)        not null, primary key
#  description         :string
#  deadline            :date
#  status              :string
#  priority            :string
#  comment             :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  profile_admin_id    :bigint(8)
#  work_id             :bigint(8)
#  profile_customer_id :bigint(8)
#  created_by_id       :bigint(8)
#  deleted_at          :datetime
#
class Job < ApplicationRecord
  include DeletedFilterConcern

  acts_as_paranoid

  belongs_to :work, optional: true
  belongs_to :profile_customer
  belongs_to :profile_admin
end
