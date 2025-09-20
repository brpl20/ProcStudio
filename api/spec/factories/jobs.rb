# frozen_string_literal: true

# == Schema Information
#
# Table name: jobs
#
#  id                  :bigint           not null, primary key
#  comment             :string
#  deadline            :date             not null
#  deleted_at          :datetime
#  description         :string
#  priority            :string
#  status              :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  created_by_id       :bigint
#  profile_customer_id :bigint
#  team_id             :bigint           not null
#  work_id             :bigint
#
# Indexes
#
#  index_jobs_on_created_by_id        (created_by_id)
#  index_jobs_on_deleted_at           (deleted_at)
#  index_jobs_on_profile_customer_id  (profile_customer_id)
#  index_jobs_on_team_id              (team_id)
#  index_jobs_on_work_id              (work_id)
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => users.id)
#  fk_rails_...  (team_id => teams.id)
#
FactoryBot.define do
  factory :job do
    description { 'MyString' }
    deadline { Time.zone.today + 1 }
    status { 'pending' }
    priority { 'medium' }
    comment { 'MyString' }
  end

  trait :job_complete do
    status { 'completed' }
    profile_customer_id { create(:profile_customer).id }
    profile_admin_id { create(:profile_admin).id }
    work_id { create(:work).id }
  end
end
