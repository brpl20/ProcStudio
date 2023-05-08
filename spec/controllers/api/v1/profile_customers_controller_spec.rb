# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::ProfileCustomersController, type: :request do
  xit 'should have a valid factory' do
    expect(FactoryBot.build(:profile_customer)).to be_valid
  end
end
