# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Honorary do
  subject(:honorary) { build(:honorary) }

  describe 'Associations' do
    it { is_expected.to belong_to(:work) }
  end

  it 'defines enum honorary_type' do
    expect(honorary).to define_enum_for(:honorary_type).with_values(
      work: 'trabalho',
      success: 'exito',
      both: 'ambos',
      bonus: 'pro_abono'
    ).backed_by_column_of_type(:string)
  end
end
