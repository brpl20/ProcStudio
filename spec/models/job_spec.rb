# frozen_string_literal: true

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
