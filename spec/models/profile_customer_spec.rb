# frozen_string_literal: true

# == Schema Information
#
# Table name: profile_customers
#
#  id             :bigint           not null, primary key
#  birth          :date
#  capacity       :string
#  civil_status   :string
#  cnpj           :string
#  company        :string
#  cpf            :string
#  customer_type  :string
#  deceased_at    :datetime
#  deleted_at     :datetime
#  document       :json
#  gender         :string
#  inss_password  :string
#  last_name      :string
#  mother_name    :string
#  name           :string
#  nationality    :string
#  nit            :string
#  number_benefit :string
#  profession     :string
#  rg             :string
#  status         :string           default("active"), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  accountant_id  :integer
#  created_by_id  :bigint
#  customer_id    :bigint           not null
#
# Indexes
#
#  index_profile_customers_on_accountant_id  (accountant_id)
#  index_profile_customers_on_created_by_id  (created_by_id)
#  index_profile_customers_on_customer_id    (customer_id)
#  index_profile_customers_on_deceased_at    (deceased_at)
#  index_profile_customers_on_deleted_at     (deleted_at)
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => users.id)
#  fk_rails_...  (customer_id => customers.id)
#
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
        status: 'active',
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

    it { is_expected.to belong_to(:customer).optional }
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

    context 'Desassociar Emails' do
      let(:profile) { create(:profile_customer) }
      let!(:email1) { create(:email) }
      let!(:email2) { create(:email) }

      before do
        profile.emails << email1
        profile.emails << email2
      end

      it 'remove a associação de um email sem excluí-lo' do
        expect(profile.emails).to contain_exactly(email1, email2)
        expect(profile.customer_emails.count).to eq(2)

        profile.update(emails_attributes: [{ id: email2.id, _destroy: 'false' }])

        expect(profile.emails.reload).to contain_exactly(email2)
        expect(profile.customer_emails.count).to eq(1)
        expect(Email.exists?(email1.id)).to be true # # Verifica que o email1 não foi excluído
      end
    end
  end
end
