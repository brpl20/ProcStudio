# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::OfficePolicy, type: :policy do
  let(:admin) { build(:profile_admin).admin }
  subject { described_class }

  permissions :index? do
    describe 'when admin is lawyer' do
      it { is_expected.to permit(admin, nil) }
    end
  end

  permissions :show? do
    describe 'when admin is lawyer' do
      it { is_expected.to permit(admin, nil) }
    end
  end

  permissions :create? do
    describe 'when admin is lawyer' do
      it { is_expected.to permit(admin, nil) }
    end
  end

  permissions :update? do
    describe 'when admin is lawyer' do
      it { is_expected.to permit(admin, nil) }
    end
  end

  permissions :destroy? do
    describe 'when admin is lawyer' do
      it { is_expected.to permit(admin, nil) }
    end
  end
end
