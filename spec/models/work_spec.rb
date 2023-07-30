# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Work do
  subject(:work) { build(:work) }

  describe 'Associations' do
    it { is_expected.to have_one(:honorary) }
    it { is_expected.to have_many_attached(:tributary_files) }
    it { is_expected.to have_many(:profile_customers) }
    it { is_expected.to have_many(:profile_admins) }
    it { is_expected.to have_many(:powers) }
    it { is_expected.to have_many(:documents) }
    it { is_expected.to have_many(:offices) }
    it { is_expected.to have_many(:recommendations) }
    it { is_expected.to have_many(:jobs) }
  end
end
