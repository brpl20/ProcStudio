# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProfileAdmin, type: :model do
  context 'Attributes' do
    it {
      is_expected.to have_attributes(
        id: nil,
        role: nil,
        name: nil,
        last_name: nil,
        gender: nil,
        oab: nil,
        rg: nil,
        cpf: nil,
        nationality: nil,
        civil_status: nil,
        birth: nil,
        mother_name: nil,
        status: nil,
        admin_id: nil,
        created_at: nil,
        updated_at: nil,
        office_id: nil,
        origin: nil
      )
    }
  end

  context 'Relations' do
    it { is_expected.to have_many(:admin_addresses).dependent(:destroy) }
    it { is_expected.to have_many(:addresses).through(:admin_addresses) }

    it { is_expected.to have_many(:admin_phones).dependent(:destroy) }
    it { is_expected.to have_many(:phones).through(:admin_phones) }

    it { is_expected.to have_many(:admin_emails).dependent(:destroy) }
    it { is_expected.to have_many(:emails).through(:admin_emails) }

    it { is_expected.to have_many(:admin_bank_accounts).dependent(:destroy) }
    it { is_expected.to have_many(:bank_accounts).through(:admin_bank_accounts) }

    it { is_expected.to have_many(:profile_admin_works).dependent(:destroy) }
    it { is_expected.to have_many(:works).through(:profile_admin_works) }

    it { is_expected.to have_many(:jobs) }

    it { is_expected.to belong_to(:admin) }
    it { is_expected.to belong_to(:office).optional(true) }
  end

  describe 'Enums' do
    it do
      is_expected.to define_enum_for(:status)
        .with_values(
          active: 'active',
          inactive: 'inactive'
        ).backed_by_column_of_type(:string)
    end

    it do
      is_expected.to define_enum_for(:civil_status)
        .with_values(
          single: 'single',
          married: 'married',
          divorced: 'divorced',
          widower: 'widower',
          union: 'union'
        ).backed_by_column_of_type(:string)
    end

    it do
      is_expected.to define_enum_for(:gender)
        .with_values(
          male: 'male',
          female: 'female',
          other: 'other'
        ).backed_by_column_of_type(:string)
    end

    it do
      is_expected.to define_enum_for(:nationality)
        .with_values(
          brazilian: 'brazilian',
          foreigner: 'foreigner'
        ).backed_by_column_of_type(:string)
    end

    it do
      is_expected.to define_enum_for(:role)
        .with_values(
          lawyer: 'lawyer',
          paralegal: 'paralegal',
          trainee: 'trainee',
          secretary: 'secretary',
          counter: 'counter',
          excounter: 'excounter',
          representant: 'representant'
        ).backed_by_column_of_type(:string)
    end
  end

  context 'Nested Attributes' do
    it { is_expected.to accept_nested_attributes_for(:admin) }
    it { is_expected.to accept_nested_attributes_for(:addresses) }
    it { is_expected.to accept_nested_attributes_for(:phones) }
    it { is_expected.to accept_nested_attributes_for(:emails) }
    it { is_expected.to accept_nested_attributes_for(:bank_accounts) }
  end

  context 'Validations' do
    it { is_expected.to validate_presence_of(:civil_status) }
    it { is_expected.to validate_presence_of(:cpf) }
    it { is_expected.to validate_presence_of(:gender) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:nationality) }
    it { is_expected.to validate_presence_of(:rg) }

    context 'when role is lawyer' do
      subject { build(:profile_admin, role: :lawyer) }

      it { is_expected.to validate_presence_of(:oab) }
    end
  end

  context 'Instance Methods' do
    it '#full_name, returns a string with first and last_name' do
      profile = build(:profile_customer)
      expect(profile.full_name).to eq("#{profile.name} #{profile.last_name}")
    end

    context '#last_email' do
      let(:profile) { create(:profile_customer) }

      it 'returns the I18n general.without email when there is no email' do
        expect(profile.last_email).to eq(I18n.t('general.without_email'))
      end

      it 'returns the last email when applicable' do
        email = Faker::Internet.email
        profile.emails << build(:email, email: email)
        expect(profile.last_email).to eq(email)
      end
    end
  end
end
