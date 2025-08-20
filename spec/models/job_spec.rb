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
require 'rails_helper'

RSpec.describe Job, type: :model do
  describe 'Attributes' do
    it 'has default attributes' do
      job = described_class.new(
        deadline: Time.zone.today,
        status: 'pending',
        profile_admin: create(:profile_admin)
      )

      expect(job.description).to be_nil
      expect(job.priority).to be_nil
      expect(job.comment).to be_nil
      expect(job.deadline).to eq(Time.zone.today)
      expect(job.status).to eq('pending')
    end
  end

  describe 'Associations' do
    it { is_expected.to belong_to(:work).optional }
    it { is_expected.to belong_to(:profile_customer).optional }
    it { is_expected.to belong_to(:profile_admin) }
  end

  describe 'Enums' do
    it 'defines status enum correctly' do
      expect(Job.statuses).to eq(
        'pending' => 'pending',
        'delayed' => 'delayed',
        'finished' => 'finished'
      )
    end
  end

  describe 'Status auto-update after find' do
    it 'changes status from pending to delayed if deadline is in the past' do
      job = described_class.create!(
        description: 'Tarefa atrasada',
        deadline: 2.days.ago,
        status: 'pending',
        profile_admin: create(:profile_admin)
      )

      expect(job.reload.status).to eq('delayed')
    end

    it 'does not change status if already finished' do
      job = described_class.create!(
        description: 'Tarefa finalizada',
        deadline: 2.days.ago,
        status: 'finished',
        profile_admin: create(:profile_admin)
      )

      expect(job.reload.status).to eq('finished')
    end

    it 'does not change status if deadline is today or in the future' do
      job = described_class.create!(
        description: 'Tarefa atual',
        deadline: Time.zone.today,
        status: 'pending',
        profile_admin: create(:profile_admin)
      )

      expect(job.reload.status).to eq('pending')
    end
  end
end
