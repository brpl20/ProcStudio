# frozen_string_literal: true

# == Schema Information
#
# Table name: job_works
#
#  id                  :bigint           not null, primary key
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  job_id              :bigint           not null
#  profile_customer_id :bigint           not null
#  user_profile_id     :bigint           not null
#  work_id             :bigint           not null
#
# Indexes
#
#  index_job_works_on_job_id               (job_id)
#  index_job_works_on_profile_customer_id  (profile_customer_id)
#  index_job_works_on_user_profile_id      (user_profile_id)
#  index_job_works_on_work_id              (work_id)
#
# Foreign Keys
#
#  fk_rails_...  (job_id => jobs.id)
#  fk_rails_...  (profile_customer_id => profile_customers.id)
#  fk_rails_...  (user_profile_id => user_profiles.id)
#  fk_rails_...  (work_id => works.id)
#

class JobWork < ApplicationRecord
  belongs_to :job
  belongs_to :work
  belongs_to :user_profile
  belongs_to :profile_customer
end
