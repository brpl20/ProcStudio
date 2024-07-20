# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProfileCustomer, type: :model do
  context 'Attributes' do
    it {
      is_expected.to have_attributes(
        id: nil,
        customer_type: nil,
        name: nil,
        last_name: nil,
        gender: nil,
        rg: nil,
        cpf: nil,
        cnpj: nil,
        nationality: nil,
        civil_status: nil,
        capacity: nil,
        profession: nil,
        company: nil,
        birth: nil,
        mother_name: nil,
        number_benefit: nil,
        status: nil,
        document: nil,
        nit: nil,
        inss_password: nil,
        invalid_person: nil,
        customer_id: nil,
        created_at: nil,
        updated_at: nil,
        accountant_id: nil
      )
    }
  end

  context 'Relations' do
    it { is_expected.to have_many(:customer_addresses).dependent(:destroy) }
    it { is_expected.to have_many(:addresses).through(:customer_addresses) }

    it { is_expected.to have_many(:customer_phones).dependent(:destroy) }
    it { is_expected.to have_many(:phones).through(:customer_phones) }

    it { is_expected.to have_many(:customer_emails).dependent(:destroy) }
    it { is_expected.to have_many(:emails).through(:customer_emails) }

    it { is_expected.to have_many(:customer_bank_accounts).dependent(:destroy) }
    it { is_expected.to have_many(:bank_accounts).through(:customer_bank_accounts) }

    it { is_expected.to have_many(:customer_works).dependent(:destroy) }
    it { is_expected.to have_many(:works).through(:customer_works) }

    it { is_expected.to have_many(:customer_files).dependent(:destroy) }

    it { is_expected.to have_one(:represent) }

    it { is_expected.to belong_to(:customer) }
    it { is_expected.to belong_to(:accountant).class_name('ProfileCustomer').optional(true) }
  end

  context 'Nested Attributes' do
    it { is_expected.to accept_nested_attributes_for(:customer_files) }
    it { is_expected.to accept_nested_attributes_for(:customer) }
    it { is_expected.to accept_nested_attributes_for(:addresses) }
    it { is_expected.to accept_nested_attributes_for(:phones) }
    it { is_expected.to accept_nested_attributes_for(:emails) }
    it { is_expected.to accept_nested_attributes_for(:bank_accounts) }
    it { is_expected.to accept_nested_attributes_for(:represent) }
  end

  context 'Validations' do
    it { is_expected.to validate_presence_of(:capacity) }
    it { is_expected.to validate_presence_of(:civil_status) }
    it { is_expected.to validate_presence_of(:cpf) }
    it { is_expected.to validate_presence_of(:gender) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:nationality) }
    it { is_expected.to validate_presence_of(:profession) }
    it { is_expected.to validate_presence_of(:rg) }

    it { is_expected.to_not validate_presence_of(:accountant) }

    describe '#phones' do
      it 'is valid with at least one phone' do
        profile = build(:profile_customer)
        profile.phones << build(:phone)
        expect(profile).to be_valid
      end

      it 'is invalid with duplicated phones' do
        profile = build(:profile_customer)
        profile.phones.build(phone_number: '123456789')
        profile.phones.build(phone_number: '123456789')
        expect(profile).to be_invalid
      end
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

    context '#unable?' do
      let(:profile) { build(:profile_customer) }

      it 'returns false if capacity is not equal to "unable"' do
        expect(profile.unable?).to eq(false)
      end

      it 'returns false if capacity is not equal to "unable"' do
        expect(profile.unable?).to eq(false)
      end
    end
  end
end
