# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Office, type: :model do
  describe 'Attributes' do
    it {
      is_expected.to have_attributes(
        id: nil,
        name: nil,
        cnpj: nil,
        oab: nil,
        society: nil,
        foundation: nil,
        site: nil,
        zip_code: nil,
        street: nil,
        number: nil,
        neighborhood: nil,
        city: nil,
        state: nil,
        office_type_id: nil,
        created_at: nil,
        updated_at: nil,
        responsible_lawyer_id: nil,
        accounting_type: nil
      )
    }
  end

  describe 'Relationships' do
    it { is_expected.to belong_to(:office_type) }
    it { is_expected.to belong_to(:responsible_lawyer).class_name('ProfileAdmin').optional }

    it { is_expected.to have_many(:profile_admins) }

    it { is_expected.to have_many(:office_phones) }
    it { is_expected.to have_many(:phones).through(:office_phones) }

    it { is_expected.to have_many(:office_emails) }
    it { is_expected.to have_many(:emails).through(:office_emails) }

    it { is_expected.to have_many(:office_bank_accounts) }
    it { is_expected.to have_many(:bank_accounts).through(:office_bank_accounts) }

    it { is_expected.to have_many(:office_works) }
    it { is_expected.to have_many(:works).through(:office_works) }
  end

  describe 'Nested Attributes' do
    it { is_expected.to accept_nested_attributes_for(:phones) }
    it { is_expected.to accept_nested_attributes_for(:emails) }
    it { is_expected.to accept_nested_attributes_for(:bank_accounts) }
  end

  context 'Validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:cnpj) }
    it { is_expected.to validate_presence_of(:city) }
    it { is_expected.to validate_presence_of(:zip_code) }
    it { is_expected.to validate_presence_of(:street) }
    it { is_expected.to validate_presence_of(:number) }
    it { is_expected.to validate_presence_of(:neighborhood) }
    it { is_expected.to validate_presence_of(:state) }
  end

  describe 'Enums' do
    it do
      is_expected.to define_enum_for(:society)
                       .with_values(
                         sole_proprietorship: 'sole_proprietorship',
                         company: 'company',
                         individual: 'individual'
                       ).backed_by_column_of_type(:string)
    end

    it do
      is_expected.to define_enum_for(:accounting_type)
                       .with_values(
                         simple: 'simple',
                         real_profit: 'real_profit',
                         presumed_profit: 'presumed_profit'
                       ).backed_by_column_of_type(:string)
    end
  end
end
