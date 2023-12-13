# frozen_string_literal: true

# == Schema Information
#
# Table name: job_works
#
#  id                  :bigint(8)        not null, primary key
#  job_id              :bigint(8)        not null
#  work_id             :bigint(8)        not null
#  profile_admin_id    :bigint(8)        not null
#  profile_customer_id :bigint(8)        not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
class JobWork < ApplicationRecord
  belongs_to :job
  belongs_to :work
  belongs_to :profile_admin
  belongs_to :profile_customer
end
