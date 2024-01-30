require 'rails_helper'

RSpec.describe Admin::BasePolicy, type: :policy do
  let!(:admin) { build(:profile_admin).admin }

  subject { described_class.new(admin, nil) }

  describe '#roles' do
    it { is_expected.to respond_to(:role) }
    it { is_expected.to respond_to(:lawyer?) }
    it { is_expected.to respond_to(:paralegal?) }
    it { is_expected.to respond_to(:trainee?) }
    it { is_expected.to respond_to(:secretary?) }
    it { is_expected.to respond_to(:counter?) }
    it { is_expected.to respond_to(:excounter?) }
    it { is_expected.to respond_to(:representant?) }
  end
end
