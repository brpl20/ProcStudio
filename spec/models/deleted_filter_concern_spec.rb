# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'DeletedFilterConcern' do
  shared_examples 'filters by deleted_at' do |*args|
    describe '.filter_by_deleted' do
      subject { record.class.filter_by_deleted(filter) }

      let(:record) { create(*args) }

      context 'when filter is "with_deleted"' do
        let(:filter) { 'with_deleted' }

        it 'returns all records' do
          expect(subject).to include(record)
        end
      end

      context 'when filter is "only_deleted"' do
        let(:filter) { 'only_deleted' }

        before { record.destroy }

        it 'returns only deleted records' do
          expect(subject).to include(record)
          expect(record.deleted?).to be_truthy
        end
      end

      context 'when filter is "invalid"' do
        let(:filter) { 'invalid' }

        it 'returns all records' do
          expect(subject).to include(record)
        end
      end
    end
  end

  it_behaves_like 'filters by deleted_at', :admin
  it_behaves_like 'filters by deleted_at', :customer
  it_behaves_like 'filters by deleted_at', :job, :job_complete
  it_behaves_like 'filters by deleted_at', :office
  it_behaves_like 'filters by deleted_at', :profile_customer
  it_behaves_like 'filters by deleted_at', :profile_admin
  it_behaves_like 'filters by deleted_at', :work
  it_behaves_like 'filters by deleted_at', :work_event
end
