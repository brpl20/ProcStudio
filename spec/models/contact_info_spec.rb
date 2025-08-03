# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ContactInfo, type: :model do
  describe 'validations' do
    it { should validate_inclusion_of(:contact_type).in_array(%w[address email phone bank_account]) }
  end

  describe 'associations' do
    it { should belong_to(:contactable) }
  end

  describe 'scopes' do
    let(:individual) { create(:individual_entity) }
    let!(:primary_email) { create(:contact_info, :email, :primary, contactable: individual) }
    let!(:secondary_email) { create(:contact_info, :email, contactable: individual) }

    describe '.primary' do
      it 'returns primary contact info' do
        expect(ContactInfo.primary).to include(primary_email)
        expect(ContactInfo.primary).not_to include(secondary_email)
      end
    end
  end

  describe 'instance methods' do
    describe '#display_value' do
      context 'for address' do
        let(:address) { create(:contact_info, :address) }

        it 'returns formatted address' do
          expected = "#{address.contact_data['street']}, #{address.contact_data['number']}, " \
                    "#{address.contact_data['neighborhood']}, #{address.contact_data['city']}, " \
                    "#{address.contact_data['state']} - #{address.contact_data['zipcode']}"
          expect(address.display_value).to eq(expected)
        end
      end

      context 'for email' do
        let(:email) { create(:contact_info, :email) }

        it 'returns email address' do
          expect(email.display_value).to eq(email.contact_data['email'])
        end
      end

      context 'for phone' do
        let(:phone) { create(:contact_info, :phone) }

        it 'returns formatted phone number' do
          number = phone.contact_data['phone_number']
          expected = "(#{number[0..1]}) #{number[2..6]}-#{number[7..10]}"
          expect(phone.display_value).to eq(expected)
        end
      end

      context 'for bank account' do
        let(:bank_account) { create(:contact_info, :bank_account) }

        it 'returns formatted bank account' do
          data = bank_account.contact_data
          expected = "#{data['bank_name']} - Ag: #{data['agency']}, CC: #{data['account_number']}"
          expect(bank_account.display_value).to eq(expected)
        end
      end
    end

    describe '#contact_type_label' do
      it 'returns correct labels for each type' do
        expect(create(:contact_info, :address).contact_type_label).to eq('Endereço')
        expect(create(:contact_info, :email).contact_type_label).to eq('E-mail')
        expect(create(:contact_info, :phone).contact_type_label).to eq('Telefone')
        expect(create(:contact_info, :bank_account).contact_type_label).to eq('Conta Bancária')
      end
    end
  end

  describe 'polymorphic associations' do
    let(:individual) { create(:individual_entity) }
    let(:legal_entity) { create(:legal_entity) }
    let(:admin) { create(:admin) }

    it 'can belong to individual entity' do
      contact = create(:contact_info, :email, contactable: individual)
      expect(contact.contactable).to eq(individual)
      expect(contact.contactable_type).to eq('IndividualEntity')
    end

    it 'can belong to legal entity' do
      contact = create(:contact_info, :address, contactable: legal_entity)
      expect(contact.contactable).to eq(legal_entity)
      expect(contact.contactable_type).to eq('LegalEntity')
    end

    it 'can belong to admin' do
      contact = create(:contact_info, :phone, contactable: admin)
      expect(contact.contactable).to eq(admin)
      expect(contact.contactable_type).to eq('Admin')
    end
  end

  describe 'data validation' do
    context 'for address' do
      let(:valid_address_data) do
        {
          'street' => 'Rua das Flores',
          'number' => '123',
          'neighborhood' => 'Centro',
          'city' => 'São Paulo',
          'state' => 'SP',
          'zipcode' => '01234567'
        }
      end

      it 'accepts valid address data' do
        contact = build(:contact_info, contact_type: 'address', contact_data: valid_address_data)
        expect(contact).to be_valid
      end
    end

    context 'for email' do
      let(:valid_email_data) do
        {
          'email' => 'test@example.com',
          'type' => 'personal'
        }
      end

      it 'accepts valid email data' do
        contact = build(:contact_info, contact_type: 'email', contact_data: valid_email_data)
        expect(contact).to be_valid
      end
    end
  end
end