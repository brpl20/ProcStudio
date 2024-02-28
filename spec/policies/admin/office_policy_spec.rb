# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::OfficePolicy, type: :policy do
  let(:admin) { build(:profile_admin).admin }
  subject { described_class }

  permissions :index? do
    describe 'when admin is lawyer' do
      it { is_expected.to permit(admin, nil) }
    end

    describe 'when admin is paralegal' do
      before { admin.profile_admin.role = :paralegal }
      it { is_expected.to permit(admin, nil) }
    end

    describe 'when admin is trainee' do
      before { admin.profile_admin.role = :trainee }
      it { is_expected.to permit(admin, nil) }
    end

    describe 'when admin is secretary' do
      before { admin.profile_admin.role = :secretary }
      it { is_expected.to permit(admin, nil) }
    end

    describe 'when admin is counter' do
      before { admin.profile_admin.role = :counter }
      it { is_expected.to permit(admin, nil) }
    end

    describe 'when admin is excounter' do
      before { admin.profile_admin.role = :excounter }
      it { is_expected.to permit(admin, nil) }
    end
  end

  permissions :show? do
    describe 'when admin is lawyer' do
      it { is_expected.to permit(admin, nil) }
    end

    describe 'when admin is paralegal' do
      before { admin.profile_admin.role = :paralegal }
      it { is_expected.to permit(admin, nil) }
    end

    describe 'when admin is trainee' do
      before { admin.profile_admin.role = :trainee }
      it { is_expected.to permit(admin, nil) }
    end

    describe 'when admin is secretary' do
      before { admin.profile_admin.role = :secretary }
      it { is_expected.to permit(admin, nil) }
    end

    describe 'when admin is counter' do
      before { admin.profile_admin.role = :counter }
      it { is_expected.to permit(admin, nil) }
    end

    describe 'when admin is excounter' do
      before { admin.profile_admin.role = :excounter }
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
