# frozen_string_literal: true

# == Schema Information
#
# Table name: drafts
#
#  id             :bigint           not null, primary key
#  data           :json             not null
#  draftable_type :string           not null
#  expires_at     :datetime
#  form_type      :string           not null
#  status         :string           default("draft")
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  customer_id    :bigint
#  draftable_id   :bigint
#  team_id        :bigint
#  user_id        :bigint
#
# Indexes
#
#  index_drafts_new_records              (team_id,user_id,form_type,draftable_type) WHERE (draftable_id IS NULL)
#  index_drafts_on_customer_id           (customer_id)
#  index_drafts_on_draftable             (draftable_type,draftable_id)
#  index_drafts_on_expires_at            (expires_at)
#  index_drafts_on_status                (status)
#  index_drafts_on_team_id               (team_id)
#  index_drafts_on_user_id               (user_id)
#  index_drafts_unique_existing_records  (team_id,draftable_type,draftable_id,form_type) UNIQUE WHERE
#                                     (draftable_id IS NOT NULL)
#
# Foreign Keys
#
#  fk_rails_...  (customer_id => customers.id)
#  fk_rails_...  (team_id => teams.id)
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe Draft, type: :model do
  describe 'associations' do
    it { should belong_to(:draftable) }
    it { should belong_to(:user).optional }
    it { should belong_to(:customer).optional }
    it { should belong_to(:team).optional }
  end

  describe 'validations' do
    subject { build(:draft) }

    it { should validate_presence_of(:form_type) }
    it { should validate_presence_of(:data) }
  end

  describe 'enums' do
    it 'defines status enum' do
      expect(Draft.statuses).to eq({ 'draft' => 'draft', 'recovered' => 'recovered', 'expired' => 'expired' })
    end
  end

  describe 'scopes' do
    let!(:active_draft) { create(:draft, status: 'draft', expires_at: 1.day.from_now) }
    let!(:expired_draft) { create(:draft, status: 'draft', expires_at: 1.day.ago) }
    let!(:recovered_draft) { create(:draft, :recovered) }
    let!(:no_expiration_draft) { create(:draft, :no_expiration, status: 'draft') }

    describe '.active' do
      it 'returns drafts with status draft and not expired' do
        expect(Draft.active).to include(active_draft, no_expiration_draft)
        expect(Draft.active).not_to include(expired_draft, recovered_draft)
      end
    end

    describe '.expired' do
      it 'returns drafts with expiration date in the past' do
        expect(Draft.expired).to include(expired_draft)
        expect(Draft.expired).not_to include(active_draft, no_expiration_draft)
      end
    end
  end

  describe 'callbacks' do
    describe 'before_validation' do
      context 'when expires_at is not set' do
        it 'sets default expiration to 30 days from now' do
          draft = Draft.new(
            draftable: create(:work),
            form_type: 'test_form',
            data: { test: 'data' }
          )

          expect(draft.expires_at).to be_nil
          draft.valid?
          expect(draft.expires_at).to be_present
          expect(draft.expires_at).to be_within(1.minute).of(30.days.from_now)
        end
      end

      context 'when expires_at is already set' do
        it 'does not override the existing expiration' do
          custom_expiration = 10.days.from_now
          draft = Draft.new(
            draftable: create(:work),
            form_type: 'test_form',
            data: { test: 'data' },
            expires_at: custom_expiration
          )

          draft.valid?
          expect(draft.expires_at).to be_within(1.second).of(custom_expiration)
        end
      end
    end
  end

  describe 'class methods' do
    describe '.save_draft' do
      let(:work) { create(:work) }
      let(:user) { create(:user) }
      let(:customer) { create(:customer) }
      let(:team) { create(:team) }
      let(:form_data) { { field1: 'value1', field2: 'value2' } }

      context 'when creating a new draft' do
        it 'creates a new draft with provided data' do
          expect do
            Draft.save_draft(
              draftable: work,
              form_type: 'work_form',
              data: form_data,
              user: user
            )
          end.to change(Draft, :count).by(1)

          draft = Draft.last
          expect(draft.draftable).to eq(work)
          expect(draft.form_type).to eq('work_form')
          expect(draft.data).to eq(form_data.stringify_keys)
          expect(draft.user).to eq(user)
          expect(draft.status).to eq('draft')
          expect(draft.expires_at).to be_within(1.minute).of(30.days.from_now)
        end
      end

      context 'when updating an existing draft' do
        let!(:existing_draft) do
          create(:draft,
                 draftable: work,
                 form_type: 'work_form',
                 team: team,
                 data: { old: 'data' })
        end

        it 'updates the existing draft instead of creating a new one' do
          expect do
            Draft.save_draft(
              draftable: work,
              form_type: 'work_form',
              data: form_data,
              team: team
            )
          end.not_to change(Draft, :count)

          existing_draft.reload
          expect(existing_draft.data).to eq(form_data.stringify_keys)
        end
      end

      context 'team determination' do
        it 'uses team from user when user is provided' do
          draft = Draft.save_draft(
            draftable: work,
            form_type: 'work_form',
            data: form_data,
            user: user
          )

          expect(draft.team).to eq(user.team)
        end

        it 'uses team from customer when customer is provided' do
          create(:team_customer, customer: customer, team: team)

          draft = Draft.save_draft(
            draftable: work,
            form_type: 'work_form',
            data: form_data,
            customer: customer
          )

          expect(draft.team).to eq(team)
        end

        it 'uses provided team when explicitly given' do
          different_team = create(:team)

          draft = Draft.save_draft(
            draftable: work,
            form_type: 'work_form',
            data: form_data,
            user: user,
            team: different_team
          )

          expect(draft.team).to eq(different_team)
        end
      end
    end

    describe '.determine_team' do
      let(:user) { create(:user) }
      let(:customer) { create(:customer) }
      let(:team) { create(:team) }

      context 'when user responds to team' do
        it 'returns user team' do
          expect(Draft.determine_team(user, nil)).to eq(user.team)
        end
      end

      context 'when customer has team association' do
        it 'returns team from team_customer' do
          create(:team_customer, customer: customer, team: team)
          expect(Draft.determine_team(nil, customer)).to eq(team)
        end
      end

      context 'when neither user nor customer have teams' do
        it 'returns default team if exists' do
          default_team = create(:team, name: 'Default')
          expect(Draft.determine_team(nil, nil)).to eq(default_team)
        end

        it 'returns nil if no default team exists' do
          expect(Draft.determine_team(nil, nil)).to be_nil
        end
      end
    end
  end

  describe 'instance methods' do
    describe '#recover!' do
      let(:draft) { create(:draft) }

      it 'changes status to recovered' do
        expect(draft.status).to eq('draft')
        draft.recover!
        expect(draft.reload.status).to eq('recovered')
      end
    end

    describe '#expired?' do
      context 'when expires_at is in the past' do
        let(:draft) { create(:draft, expires_at: 1.day.ago) }

        it 'returns true' do
          expect(draft.expired?).to be true
        end
      end

      context 'when expires_at is in the future' do
        let(:draft) { create(:draft, expires_at: 1.day.from_now) }

        it 'returns false' do
          expect(draft.expired?).to be false
        end
      end

      context 'when expires_at is nil' do
        let(:draft) { create(:draft, expires_at: nil) }

        it 'returns false' do
          expect(draft.expired?).to be false
        end
      end
    end

    describe '#mark_expired!' do
      let(:draft) { create(:draft) }

      it 'changes status to expired' do
        expect(draft.status).to eq('draft')
        draft.mark_expired!
        expect(draft.reload.status).to eq('expired')
      end
    end
  end

  describe 'polymorphic association' do
    it 'can belong to different draftable types' do
      work = create(:work)
      # Create different draft for polymorphic test
      work_draft = create(:draft, draftable: work, form_type: 'work_form')

      expect(work_draft.draftable_type).to eq('Work')
      expect(work_draft.draftable_id).to eq(work.id)
    end
  end

  describe 'data storage' do
    let(:draft) { create(:draft, :complex_data) }

    it 'stores complex JSON data' do
      expect(draft.data).to be_a(Hash)
      expect(draft.data['personal_info']).to be_present
      expect(draft.data['preferences']).to be_present
      expect(draft.data['metadata']).to be_present
    end

    it 'preserves data types in JSON' do
      draft = create(:draft, data: {
                       string: 'text',
                       number: 42,
                       boolean: true,
                       array: [1, 2, 3],
                       nested: { key: 'value' }
                     })

      draft.reload
      expect(draft.data['string']).to eq('text')
      expect(draft.data['number']).to eq(42)
      expect(draft.data['boolean']).to eq(true)
      expect(draft.data['array']).to eq([1, 2, 3])
      expect(draft.data['nested']).to eq({ 'key' => 'value' })
    end
  end

  describe 'unique constraint' do
    let(:team) { create(:team) }
    let(:work) { create(:work) }

    it 'enforces uniqueness of team, draftable, and form_type combination' do
      create(:draft, team: team, draftable: work, form_type: 'form1')

      duplicate_draft = build(:draft, team: team, draftable: work, form_type: 'form1')

      expect do
        duplicate_draft.save!(validate: false) # Skip validations to test DB constraint
      end.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it 'allows different form_types for same team and draftable' do
      create(:draft, team: team, draftable: work, form_type: 'form1')

      different_form_draft = build(:draft, team: team, draftable: work, form_type: 'form2')
      expect(different_form_draft).to be_valid
    end
  end
end
