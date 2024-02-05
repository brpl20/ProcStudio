# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::CustomerPolicy, type: :policy do
  let(:admin) { build(:profile_admin).admin }
  subject { described_class }

  describe 'when admin is lawyer' do
    permissions :index? do
      it { is_expected.to permit(admin, nil) }
    end

    permissions :show? do
      it { is_expected.to permit(admin, nil) }
    end

    permissions :create? do
      it { is_expected.to permit(admin, nil) }
    end

    permissions :update? do
      it { is_expected.to permit(admin, nil) }
    end

    permissions :destroy? do
      it { is_expected.to permit(admin, nil) }
    end
  end

  describe 'when admin is paralegal' do
    before { admin.profile_admin.role = :paralegal }

    permissions :index? do
      it { is_expected.to permit(admin, nil) }
    end

    permissions :show? do
      it { is_expected.to permit(admin, nil) }
    end

    permissions :create? do
      it { is_expected.to permit(admin, nil) }
    end

    permissions :update? do
      it { is_expected.to permit(admin, nil) }
    end

    permissions :destroy? do
      it { is_expected.not_to permit(admin, nil) }
    end
  end

  describe 'when admin is trainee' do
    before { admin.profile_admin.role = :trainee }

    permissions :index? do
      it { is_expected.to permit(admin, nil) }
    end

    permissions :show? do
      it { is_expected.to permit(admin, nil) }
    end

    permissions :create? do
      it { is_expected.to permit(admin, nil) }
    end

    permissions :update? do
      it { is_expected.to permit(admin, nil) }
    end

    permissions :destroy? do
      it { is_expected.not_to permit(admin, nil) }
    end
  end

  describe 'when admin is secretary' do
    before { admin.profile_admin.role = :secretary }

    permissions :index? do
      it { is_expected.to permit(admin, nil) }
    end

    permissions :show? do
      it { is_expected.to permit(admin, nil) }
    end

    permissions :create? do
      it { is_expected.to permit(admin, nil) }
    end

    permissions :update? do
      it { is_expected.to permit(admin, nil) }
    end

    permissions :destroy? do
      it { is_expected.not_to permit(admin, nil) }
    end
  end

  describe 'when admin is counter' do
    before { admin.profile_admin.role = :counter }

    permissions :index? do
      it { is_expected.to permit(admin, nil) }
    end

    permissions :show? do
      it { is_expected.to permit(admin, nil) }
    end

    permissions :create? do
      it { is_expected.to permit(admin, nil) }
    end

    permissions :update? do
      it { is_expected.to permit(admin, nil) }
    end

    permissions :destroy? do
      it { is_expected.not_to permit(admin, nil) }
    end
  end

  describe 'when admin is excounter' do
    before { admin.profile_admin.role = :excounter }

    permissions :index? do
      it { is_expected.to permit(admin, nil) }
    end

    permissions :show? do
      it { is_expected.to permit(admin, nil) }
    end

    permissions :create? do
      it { is_expected.not_to permit(admin, nil) }
    end

    permissions :update? do
      it { is_expected.not_to permit(admin, nil) }
    end

    permissions :destroy? do
      it { is_expected.not_to permit(admin, nil) }
    end
  end
end
