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

    it { is_expected.to have_many(:represents).dependent(:destroy) }
    it { is_expected.to have_many(:representors).through(:represents) }
    it { is_expected.to have_many(:active_represents) }
    it { is_expected.to have_many(:active_representors).through(:active_represents) }
    it {
      is_expected.to have_many(:represented_customers)
                       .class_name('Represent')
                       .with_foreign_key('representor_id')
                       .dependent(:nullify)
    }

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
    it { is_expected.to accept_nested_attributes_for(:represents) }
    it { is_expected.to accept_nested_attributes_for(:customer_emails).allow_destroy(true) }

    describe 'creating with nested attributes' do
      let(:customer) { create(:customer) }

      context 'with addresses' do
        it 'creates profile with addresses through nested attributes' do
          # Don't use factory attributes that may include addresses
          profile_attributes = {
            name: 'John',
            last_name: 'Doe',
            customer_type: 'physical_person',
            gender: 'male',
            rg: '123456',
            cpf: '11144477735',
            nationality: 'brazilian',
            civil_status: 'single',
            capacity: 'able',
            profession: 'Developer',
            customer_id: customer.id,
            addresses_attributes: [
              {
                street: 'Main Street',
                number: 123,
                neighborhood: 'Downtown',
                city: 'São Paulo',
                state: 'SP',
                zip_code: '01000-000',
                description: 'Apt 101'
              },
              {
                street: 'Second Avenue',
                number: 456,
                neighborhood: 'Uptown',
                city: 'Rio de Janeiro',
                state: 'RJ',
                zip_code: '20000-000',
                description: 'Suite 202'
              }
            ]
          }

          profile = ProfileCustomer.create!(profile_attributes)

          expect(profile.addresses.count).to eq(2)
          expect(profile.addresses.first.street).to eq('Main Street')
          expect(profile.addresses.last.street).to eq('Second Avenue')
          expect(profile.customer_addresses.count).to eq(2)
        end

        it 'rejects blank address attributes' do
          # Don't use factory attributes that may include addresses
          profile_attributes = {
            name: 'John',
            last_name: 'Doe',
            customer_type: 'physical_person',
            gender: 'male',
            rg: '123456',
            cpf: '11144477735',
            nationality: 'brazilian',
            civil_status: 'single',
            capacity: 'able',
            profession: 'Developer',
            customer_id: customer.id,
            addresses_attributes: [
              { street: '', number: '', city: '' },
              { street: 'Valid Street', number: 789, city: 'São Paulo', state: 'SP', zip_code: '01000-000' }
            ]
          }

          profile = ProfileCustomer.create!(profile_attributes)

          expect(profile.addresses.count).to eq(1)
          expect(profile.addresses.first.street).to eq('Valid Street')
        end
      end

      context 'with phones' do
        it 'creates profile with phones through nested attributes' do
          profile_attributes = attributes_for(:profile_customer).merge(
            customer_id: customer.id,
            phones_attributes: [
              { phone_number: '11999887766' },
              { phone_number: '1133445566' }
            ]
          )

          profile = ProfileCustomer.create!(profile_attributes)

          expect(profile.phones.count).to eq(2)
          expect(profile.phones.pluck(:phone_number)).to contain_exactly('11999887766', '1133445566')
          expect(profile.customer_phones.count).to eq(2)
        end

        it 'rejects blank phone attributes' do
          profile_attributes = attributes_for(:profile_customer).merge(
            customer_id: customer.id,
            phones_attributes: [
              { phone_number: '' },
              { phone_number: '11999887766' }
            ]
          )

          profile = ProfileCustomer.create!(profile_attributes)

          expect(profile.phones.count).to eq(1)
          expect(profile.phones.first.phone_number).to eq('11999887766')
        end
      end

      context 'with emails' do
        it 'creates profile with emails through nested attributes' do
          profile_attributes = attributes_for(:profile_customer).merge(
            customer_id: customer.id,
            emails_attributes: [
              { email: 'user1@example.com' },
              { email: 'user2@example.com' }
            ]
          )

          profile = ProfileCustomer.create!(profile_attributes)

          expect(profile.emails.count).to eq(2)
          expect(profile.emails.pluck(:email)).to contain_exactly('user1@example.com', 'user2@example.com')
          expect(profile.customer_emails.count).to eq(2)
        end

        it 'rejects blank email attributes' do
          profile_attributes = attributes_for(:profile_customer).merge(
            customer_id: customer.id,
            emails_attributes: [
              { email: '' },
              { email: 'valid@example.com' }
            ]
          )

          profile = ProfileCustomer.create!(profile_attributes)

          expect(profile.emails.count).to eq(1)
          expect(profile.emails.first.email).to eq('valid@example.com')
        end
      end

      context 'with bank_accounts' do
        it 'creates profile with bank accounts through nested attributes' do
          profile_attributes = attributes_for(:profile_customer).merge(
            customer_id: customer.id,
            bank_accounts_attributes: [
              {
                bank_name: 'Banco do Brasil',
                agency: '1234',
                account: '56789-0'
              },
              {
                bank_name: 'Itaú',
                agency: '5678',
                account: '12345-6'
              }
            ]
          )

          profile = ProfileCustomer.create!(profile_attributes)

          expect(profile.bank_accounts.count).to eq(2)
          expect(profile.bank_accounts.pluck(:bank_name)).to contain_exactly('Banco do Brasil', 'Itaú')
          expect(profile.customer_bank_accounts.count).to eq(2)
        end

        it 'rejects blank bank account attributes' do
          profile_attributes = attributes_for(:profile_customer).merge(
            customer_id: customer.id,
            bank_accounts_attributes: [
              { bank_name: '', agency: '', account: '' },
              { bank_name: 'Valid Bank', agency: '1234', account: '56789-0' }
            ]
          )

          profile = ProfileCustomer.create!(profile_attributes)

          expect(profile.bank_accounts.count).to eq(1)
          expect(profile.bank_accounts.first.bank_name).to eq('Valid Bank')
        end
      end

      context 'with multiple nested associations' do
        it 'creates profile with all nested associations at once' do
          # Don't use factory attributes that may include addresses
          profile_attributes = {
            name: 'John',
            last_name: 'Doe',
            customer_type: 'physical_person',
            gender: 'male',
            rg: '123456',
            cpf: '11144477735',
            nationality: 'brazilian',
            civil_status: 'single',
            capacity: 'able',
            profession: 'Developer',
            customer_id: customer.id,
            addresses_attributes: [
              { street: 'Main St', number: 100, city: 'São Paulo', state: 'SP', zip_code: '01000-000' }
            ],
            phones_attributes: [
              { phone_number: '11999887766' }
            ],
            emails_attributes: [
              { email: 'test@example.com' }
            ],
            bank_accounts_attributes: [
              { bank_name: 'Test Bank', agency: '0001', account: '12345-6' }
            ]
          }

          profile = ProfileCustomer.create!(profile_attributes)

          expect(profile.addresses.count).to eq(1)
          expect(profile.phones.count).to eq(1)
          expect(profile.emails.count).to eq(1)
          expect(profile.bank_accounts.count).to eq(1)
        end
      end
    end

    describe 'updating with nested attributes' do
      let(:profile) { create(:profile_customer) }

      context 'updating addresses' do
        let!(:address) { create(:address) }

        before do
          profile.addresses << address
        end

        it 'updates existing addresses through nested attributes' do
          profile.update!(
            addresses_attributes: [
              {
                id: address.id,
                street: 'Updated Street',
                number: 999
              }
            ]
          )

          address.reload
          expect(address.street).to eq('Updated Street')
          expect(address.number).to eq(999)
        end

        it 'adds new addresses while updating existing ones' do
          initial_count = profile.addresses.count

          profile.update!(
            addresses_attributes: [
              {
                id: address.id,
                street: 'Updated Street'
              },
              {
                street: 'New Street',
                number: 200,
                city: 'São Paulo',
                state: 'SP',
                zip_code: '01000-000'
              }
            ]
          )

          expect(profile.addresses.count).to eq(initial_count + 1)
          expect(profile.addresses.pluck(:street)).to include('Updated Street', 'New Street')
        end
      end

      context 'with customer_emails and allow_destroy' do
        let!(:email1) { create(:email, email: 'keep@example.com') }
        let!(:email2) { create(:email, email: 'destroy@example.com') }

        before do
          profile.emails << [email1, email2]
        end

        it 'destroys customer_email association when _destroy is true' do
          expect(profile.customer_emails.count).to eq(2)
          expect(profile.emails.count).to eq(2)

          profile.update!(
            customer_emails_attributes: [
              {
                id: profile.customer_emails.find_by(email: email2).id,
                _destroy: true
              }
            ]
          )

          profile.reload
          expect(profile.customer_emails.count).to eq(1)
          expect(profile.emails.count).to eq(1)
          expect(profile.emails.first.email).to eq('keep@example.com')
          expect(Email.exists?(email2.id)).to be true # Email itself is not destroyed
        end

        it 'updates customer_email when _destroy is false or not present' do
          customer_email = profile.customer_emails.find_by(email: email1)

          profile.update!(
            customer_emails_attributes: [
              {
                id: customer_email.id,
                _destroy: false
              }
            ]
          )

          profile.reload
          expect(profile.customer_emails.count).to eq(2)
          expect(profile.emails).to include(email1, email2)
        end
      end

      context 'with represents nested attributes' do
        it 'creates represents associations through nested attributes' do
          representor = create(:profile_customer)

          team = create(:team) # Assuming team factory exists
          profile.update!(
            represents_attributes: [
              {
                representor_id: representor.id,
                relationship_type: 'representation',
                start_date: Date.current,
                active: true,
                team_id: team.id
              }
            ]
          )

          expect(profile.represents.count).to eq(1)
          expect(profile.representors).to include(representor)
          expect(profile.represents.first.relationship_type).to eq('representation')
        end
      end

      context 'with customer nested attributes' do
        it 'updates associated customer through nested attributes' do
          customer = profile.customer

          profile.update!(
            customer_attributes: {
              id: customer.id,
              email: 'updated@example.com'
            }
          )

          customer.reload
          expect(customer.email).to eq('updated@example.com')
        end
      end
    end

    describe 'error handling with nested attributes' do
      let(:customer) { create(:customer) }

      it 'rolls back all changes when nested attribute validation fails' do
        initial_profile_count = ProfileCustomer.count
        initial_address_count = Address.count

        # Use an invalid ProfileCustomer attribute to trigger rollback
        profile_attributes = attributes_for(:profile_customer).merge(
          customer_id: customer.id,
          cpf: 'invalid_cpf', # Invalid CPF format will trigger validation error
          addresses_attributes: [
            { street: 'Test Street', number: 123, city: 'São Paulo', state: 'SP', zip_code: '01000-000' }
          ]
        )

        expect do
          ProfileCustomer.create!(profile_attributes)
        end.to raise_error(ActiveRecord::RecordInvalid)

        expect(ProfileCustomer.count).to eq(initial_profile_count)
        expect(Address.count).to eq(initial_address_count)
      end
    end
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

    context 'capacity enum predicate methods' do
      let(:profile) { build(:profile_customer) }

      describe '#unable?' do
        it 'returns true when capacity is unable' do
          profile.capacity = 'unable'
          expect(profile.unable?).to be true
        end

        it 'returns false when capacity is not unable' do
          profile.capacity = 'able'
          expect(profile.unable?).to be false
        end
      end

      describe '#able?' do
        it 'returns true when capacity is able' do
          profile.capacity = 'able'
          expect(profile.able?).to be true
        end

        it 'returns false when capacity is not able' do
          profile.capacity = 'unable'
          expect(profile.able?).to be false
        end
      end

      describe '#relatively?' do
        it 'returns true when capacity is relatively' do
          profile.capacity = 'relatively'
          expect(profile.relatively?).to be true
        end

        it 'returns false when capacity is not relatively' do
          profile.capacity = 'able'
          expect(profile.relatively?).to be false
        end
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

        # Remove email1 by not including it in the update
        profile.customer_emails.find_by(email: email1).destroy

        profile.reload
        expect(profile.emails).to contain_exactly(email2)
        expect(profile.customer_emails.count).to eq(1)
        expect(Email.exists?(email1.id)).to be true # Verifica que o email1 não foi excluído
      end
    end
  end
end
