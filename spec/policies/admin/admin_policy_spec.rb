# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::AdminPolicy, type: :policy do
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

    permissions :restore? do
      it { is_expected.to permit(admin, nil) }
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
      it { is_expected.to_not permit(admin, nil) }
    end

    permissions :update? do
      it { is_expected.to_not permit(admin, nil) }
    end

    permissions :destroy? do
      it { is_expected.to_not permit(admin, nil) }
    end

    permissions :restore? do
      it { is_expected.to_not permit(admin, nil) }
    end
  end
end
