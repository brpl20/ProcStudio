# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DraftService do
  describe '.auto_save' do
    let(:work) { create(:work) }
    let(:user) { create(:user) }
    let(:customer) { create(:customer) }
    let(:team) { create(:team) }
    let(:form_type) { 'work_form' }
    let(:valid_data) { { name: 'John Doe', email: 'john@example.com' } }

    context 'when data should be saved' do
      it 'creates a draft with sanitized data' do
        expect do
          DraftService.auto_save(
            draftable: work,
            form_type: form_type,
            data: valid_data,
            user: user
          )
        end.to change(Draft, :count).by(1)

        draft = Draft.last
        expect(draft.draftable).to eq(work)
        expect(draft.form_type).to eq(form_type)
        expect(draft.user).to eq(user)
      end

      it 'sanitizes string values by stripping whitespace' do
        data = { name: '  John Doe  ', email: '  john@example.com  ' }

        draft = DraftService.auto_save(
          draftable: work,
          form_type: form_type,
          data: data,
          user: user
        )

        expect(draft.data['name']).to eq('John Doe')
        expect(draft.data['email']).to eq('john@example.com')
      end

      it 'sanitizes array values by removing blank entries' do
        data = { tags: ['ruby', '', nil, 'rails', '  '] }

        draft = DraftService.auto_save(
          draftable: work,
          form_type: form_type,
          data: data
        )

        expect(draft.data['tags']).to eq(['ruby', 'rails'])
      end

      it 'schedules cleanup job' do
        expect(DraftCleanupJob).to receive(:perform_in).with(1.day)

        DraftService.auto_save(
          draftable: work,
          form_type: form_type,
          data: valid_data
        )
      end

      it 'handles cleanup job scheduling errors gracefully' do
        allow(DraftCleanupJob).to receive(:perform_in).and_raise(StandardError.new('Job error'))

        expect(Rails.logger).to receive(:error).with(/Failed to schedule draft cleanup/)

        expect do
          DraftService.auto_save(
            draftable: work,
            form_type: form_type,
            data: valid_data
          )
        end.not_to raise_error
      end

      it 'uses transaction for data integrity' do
        allow(Draft).to receive(:save_draft).and_raise(ActiveRecord::RecordInvalid)

        expect do
          DraftService.auto_save(
            draftable: work,
            form_type: form_type,
            data: valid_data
          )
        end.to raise_error(ActiveRecord::RecordInvalid)
                 .and not_change(Draft, :count)
      end
    end

    context 'when data should not be saved' do
      it 'returns nil for blank data' do
        result = DraftService.auto_save(
          draftable: work,
          form_type: form_type,
          data: {}
        )

        expect(result).to be_nil
        expect(Draft.count).to eq(0)
      end

      it 'returns nil for data with only empty values' do
        data = { name: '', email: '', tags: [] }

        result = DraftService.auto_save(
          draftable: work,
          form_type: form_type,
          data: data
        )

        expect(result).to be_nil
        expect(Draft.count).to eq(0)
      end

      it 'returns nil for nil data' do
        result = DraftService.auto_save(
          draftable: work,
          form_type: form_type,
          data: nil
        )

        expect(result).to be_nil
      end
    end
  end

  describe '.recover_draft' do
    let(:work) { create(:work) }
    let(:user) { create(:user) }
    let(:customer) { create(:customer) }
    let(:form_type) { 'work_form' }
    let(:draft_data) { { name: 'John Doe', email: 'john@example.com' } }

    context 'when an active draft exists' do
      let!(:draft) do
        create(:draft,
               draftable: work,
               form_type: form_type,
               data: draft_data,
               user: user,
               status: 'draft')
      end

      it 'returns draft information for matching user' do
        result = DraftService.recover_draft(
          draftable: work,
          form_type: form_type,
          user: user
        )

        expect(result).to be_present
        expect(result[:id]).to eq(draft.id)
        expect(result[:data]).to eq(draft.data)
        expect(result[:expires_at]).to eq(draft.expires_at)
        expect(result[:created_at]).to eq(draft.created_at)
      end

      it 'returns draft information for matching customer' do
        customer_draft = create(:draft,
                                draftable: work,
                                form_type: form_type,
                                data: draft_data,
                                customer: customer,
                                status: 'draft')

        result = DraftService.recover_draft(
          draftable: work,
          form_type: form_type,
          customer: customer
        )

        expect(result[:id]).to eq(customer_draft.id)
      end

      it 'returns nil for non-matching user' do
        different_user = create(:user)

        result = DraftService.recover_draft(
          draftable: work,
          form_type: form_type,
          user: different_user
        )

        expect(result).to be_nil
      end
    end

    context 'when no active draft exists' do
      it 'returns nil when no draft found' do
        result = DraftService.recover_draft(
          draftable: work,
          form_type: form_type,
          user: user
        )

        expect(result).to be_nil
      end

      it 'returns nil for expired drafts' do
        create(:draft,
               draftable: work,
               form_type: form_type,
               user: user,
               status: 'expired')

        result = DraftService.recover_draft(
          draftable: work,
          form_type: form_type,
          user: user
        )

        expect(result).to be_nil
      end

      it 'returns nil for recovered drafts' do
        create(:draft,
               draftable: work,
               form_type: form_type,
               user: user,
               status: 'recovered')

        result = DraftService.recover_draft(
          draftable: work,
          form_type: form_type,
          user: user
        )

        expect(result).to be_nil
      end
    end
  end

  describe '.merge_with_current' do
    let(:draft_data) do
      {
        'name' => 'Draft Name',
        'email' => 'draft@example.com',
        'phone' => '123456789',
        'nested' => {
          'field1' => 'draft_value1',
          'field2' => 'draft_value2'
        }
      }
    end

    context 'when current data has values' do
      let(:current_data) do
        {
          'name' => 'Current Name',
          'email' => '',
          'address' => '123 Main St',
          'nested' => {
            'field1' => 'current_value1',
            'field3' => 'current_value3'
          }
        }
      end

      it 'prioritizes current non-empty values over draft values' do
        result = DraftService.merge_with_current(current_data, draft_data)

        expect(result['name']).to eq('Current Name')
        expect(result['email']).to eq('draft@example.com') # Empty current value, use draft
        expect(result['phone']).to eq('123456789') # Only in draft
        expect(result['address']).to eq('123 Main St') # Only in current
        expect(result['nested']['field1']).to eq('current_value1')
        expect(result['nested']['field2']).to eq('draft_value2')
        expect(result['nested']['field3']).to eq('current_value3')
      end
    end

    context 'when draft data is blank' do
      it 'returns current data unchanged' do
        current_data = { 'name' => 'Current' }

        result = DraftService.merge_with_current(current_data, {})
        expect(result).to eq(current_data)

        result = DraftService.merge_with_current(current_data, nil)
        expect(result).to eq(current_data)
      end
    end

    context 'when current data is empty' do
      it 'uses draft values for all fields' do
        result = DraftService.merge_with_current({}, draft_data)
        expect(result).to eq(draft_data)
      end
    end

    context 'with complex nested structures' do
      it 'handles deep merging correctly' do
        draft_data = {
          'level1' => {
            'level2' => {
              'level3' => {
                'draft_field' => 'draft_value'
              }
            }
          }
        }

        current_data = {
          'level1' => {
            'level2' => {
              'level3' => {
                'current_field' => 'current_value'
              }
            }
          }
        }

        result = DraftService.merge_with_current(current_data, draft_data)

        expect(result['level1']['level2']['level3']['draft_field']).to eq('draft_value')
        expect(result['level1']['level2']['level3']['current_field']).to eq('current_value')
      end
    end
  end

  describe '.cleanup_expired_drafts' do
    let!(:active_draft) { create(:draft, expires_at: 1.day.from_now, status: 'draft') }
    let!(:expired_recent) { create(:draft, expires_at: 1.day.ago, status: 'draft') }
    let!(:expired_old) do
      draft = create(:draft, expires_at: 10.days.ago, status: 'expired')
      draft.update_column(:updated_at, 8.days.ago) # rubocop:disable Rails/SkipsModelValidations
      draft
    end
    let!(:expired_very_old) do
      draft = create(:draft, expires_at: 15.days.ago, status: 'expired')
      draft.update_column(:updated_at, 10.days.ago) # rubocop:disable Rails/SkipsModelValidations
      draft
    end

    it 'marks expired drafts as expired status' do
      expect do
        DraftService.cleanup_expired_drafts
      end.to change { expired_recent.reload.status }.from('draft').to('expired')
    end

    it 'does not affect active drafts' do
      DraftService.cleanup_expired_drafts
      expect(active_draft.reload.status).to eq('draft')
    end

    it 'destroys expired drafts older than 7 days' do
      expect do
        DraftService.cleanup_expired_drafts
      end.to change(Draft, :count).by(-1)

      expect(Draft.exists?(expired_very_old.id)).to be false
      expect(Draft.exists?(expired_old.id)).to be true
    end

    it 'handles both marking and deletion in one operation' do
      DraftService.cleanup_expired_drafts

      expect(expired_recent.reload.status).to eq('expired')
      expect(Draft.exists?(expired_very_old.id)).to be false
      expect(active_draft.reload.status).to eq('draft')
    end
  end

  describe 'private methods' do
    describe '#should_save_draft?' do
      it 'returns false for blank data' do
        expect(DraftService.send(:should_save_draft?, {})).to be false
        expect(DraftService.send(:should_save_draft?, nil)).to be false
      end

      it 'returns false for data with only empty values' do
        data = { name: '', email: '', tags: [] }
        expect(DraftService.send(:should_save_draft?, data)).to be false
      end

      it 'returns true for data with at least one present value' do
        data = { name: 'John', email: '' }
        expect(DraftService.send(:should_save_draft?, data)).to be true
      end
    end

    describe '#sanitize_data' do
      it 'strips whitespace from strings' do
        data = { name: '  John  ', email: '  test@example.com  ' }
        result = DraftService.send(:sanitize_data, data)

        expect(result[:name]).to eq('John')
        expect(result[:email]).to eq('test@example.com')
      end

      it 'removes blank values from arrays' do
        data = { tags: ['ruby', '', nil, 'rails', '  '] }
        result = DraftService.send(:sanitize_data, data)

        expect(result[:tags]).to eq(['ruby', 'rails'])
      end

      it 'handles nested data structures' do
        data = {
          user: {
            name: '  John  ',
            tags: ['', 'ruby', nil]
          }
        }

        result = DraftService.send(:sanitize_data, data)

        expect(result[:user][:name]).to eq('John')
        expect(result[:user][:tags]).to eq(['ruby'])
      end

      it 'preserves other data types' do
        data = { count: 42, active: true, date: Time.zone.today }
        result = DraftService.send(:sanitize_data, data)

        expect(result).to eq(data)
      end
    end
  end
end
