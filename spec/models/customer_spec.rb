# frozen_string_literal: true

# == Schema Information
#
# Table name: customers
#
#  id                     :bigint           not null, primary key
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  deleted_at             :datetime
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  jwt_token              :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  status                 :string           default("active"), not null
#  unconfirmed_email      :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  created_by_id          :bigint
#
# Indexes
#
#  index_customers_on_confirmation_token       (confirmation_token) UNIQUE
#  index_customers_on_created_by_id            (created_by_id)
#  index_customers_on_deleted_at               (deleted_at)
#  index_customers_on_email_where_not_deleted  (email) UNIQUE WHERE (deleted_at IS NULL)
#  index_customers_on_reset_password_token     (reset_password_token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => users.id)
#
require 'rails_helper'

RSpec.describe Customer, type: :model do
  describe 'associations' do
    it { should have_one(:profile_customer).dependent(:destroy) }
    it { should have_many(:team_customers).dependent(:destroy) }
    it { should have_many(:teams).through(:team_customers) }
  end

  describe 'validations' do
    subject { build(:customer) }

    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).ignoring_case_sensitivity }

    context 'password validations' do
      context 'when creating a new record' do
        it 'validates password presence' do
          customer = Customer.new(email: 'test@example.com')
          # Don't trigger setup_password callback
          customer.instance_eval { @password = nil }
          expect(customer).not_to be_valid
          expect(customer.errors[:password]).to include(I18n.t('errors.messages.blank'))
        end

        it 'validates password confirmation' do
          customer = build(:customer, password: 'password123', password_confirmation: 'different')
          expect(customer).not_to be_valid
          expect(customer.errors[:password_confirmation]).to include(I18n.t('errors.messages.confirmation', attribute: 'Password'))
        end

        it 'validates password length' do
          customer = build(:customer, password: 'short', password_confirmation: 'short')
          expect(customer).not_to be_valid
          expect(customer.errors[:password]).to include(I18n.t('errors.messages.too_short', count: 6))
        end
      end

      context 'when updating an existing record' do
        let(:customer) { create(:customer) }

        it 'does not require password when not changing it' do
          customer.email = 'newemail@example.com'
          expect(customer).to be_valid
        end

        it 'validates password when changing it' do
          customer.password = 'new'
          customer.password_confirmation = 'new'
          expect(customer).not_to be_valid
          expect(customer.errors[:password]).to include(I18n.t('errors.messages.too_short', count: 6))
        end
      end
    end

    context 'email format validation' do
      it 'accepts valid email formats' do
        valid_emails = ['user@example.com', 'test.user@domain.co.uk', 'user+tag@example.org']
        valid_emails.each do |email|
          customer = build(:customer, email: email)
          expect(customer).to be_valid
        end
      end

      it 'rejects invalid email formats' do
        invalid_emails = ['invalid', '@example.com', 'user@', 'user @example.com']
        invalid_emails.each do |email|
          customer = build(:customer, email: email)
          expect(customer).not_to be_valid
          expect(customer.errors[:email]).to include(I18n.t('errors.messages.invalid'))
        end
      end
    end

    context 'when customer is an unable person' do
      let(:customer) { build(:customer) }
      let(:profile) { build(:profile_customer, capacity: 'unable') }

      before do
        allow(customer).to receive(:profile_customer).and_return(profile)
        allow(customer).to receive(:unable_person?).and_return(true)
      end

      it 'allows duplicate emails for unable persons' do
        create(:customer, email: 'guardian@example.com')
        customer.email = 'guardian@example.com'
        expect(customer).to be_valid
      end
    end
  end

  describe 'enums' do
    it 'defines status enum' do
      expect(Customer.statuses).to eq({ 'active' => 'active', 'inactive' => 'inactive' })
    end
  end

  describe 'callbacks' do
    describe '#setup_password' do
      context 'when creating a new customer without password' do
        it 'generates a random password' do
          customer = Customer.new(email: 'test@example.com')
          expect(customer.password).to be_nil
          customer.send(:setup_password)
          expect(customer.password).to be_present
          expect(customer.password.length).to eq(24)
        end
      end

      context 'when creating a new customer with password' do
        it 'does not override the provided password' do
          customer = Customer.new(email: 'test@example.com', password: 'custom_password')
          customer.valid?
          expect(customer.password).to eq('custom_password')
        end
      end

      context 'when updating an existing customer' do
        it 'does not generate a new password' do
          customer = create(:customer)
          original_password = customer.encrypted_password
          customer.update(email: 'newemail@example.com')
          expect(customer.encrypted_password).to eq(original_password)
        end
      end
    end
  end

  describe 'devise modules' do
    it 'includes database_authenticatable module' do
      expect(Customer.devise_modules).to include(:database_authenticatable)
    end

    it 'includes registerable module' do
      expect(Customer.devise_modules).to include(:registerable)
    end

    it 'includes recoverable module' do
      expect(Customer.devise_modules).to include(:recoverable)
    end

    it 'includes rememberable module' do
      expect(Customer.devise_modules).to include(:rememberable)
    end

    it 'includes confirmable module' do
      expect(Customer.devise_modules).to include(:confirmable)
    end
  end

  describe 'delegations' do
    let(:customer) { create(:customer) }
    let(:profile) { create(:profile_customer, customer: customer, full_name: 'John Doe') }

    it 'delegates full_name to profile_customer' do
      profile # Ensure profile is created
      expect(customer.profile_customer_full_name).to eq('John Doe')
    end

    it 'returns nil when profile_customer is not present' do
      expect(customer.profile_customer_full_name).to be_nil
    end
  end

  describe 'instance methods' do
    describe '#password_required?' do
      context 'for new record' do
        let(:customer) { build(:customer) }

        it 'returns true' do
          expect(customer.password_required?).to be true
        end
      end

      context 'for persisted record' do
        let(:customer) { create(:customer) }

        it 'returns false when password is not being changed' do
          customer.reload # Clear any password attributes from creation
          expect(customer.password_required?).to be false
        end

        it 'returns true when password is being set' do
          customer.password = 'newpassword'
          expect(customer.password_required?).to be true
        end

        it 'returns true when password_confirmation is being set' do
          customer.password_confirmation = 'newpassword'
          expect(customer.password_required?).to be true
        end
      end
    end

    describe '#email_required?' do
      it 'always returns true' do
        customer = build(:customer)
        expect(customer.email_required?).to be true
      end
    end

    describe '#unable_person?' do
      let(:customer) { create(:customer) }

      context 'when profile_customer exists and is unable' do
        let(:profile) { create(:profile_customer, customer: customer, birth: 10.years.ago) }

        it 'returns true' do
          profile # Ensure profile is created
          customer.reload
          expect(customer.unable_person?).to be true
        end
      end

      context 'when profile_customer exists and is not unable' do
        let(:profile) { create(:profile_customer, customer: customer, birth: 25.years.ago) }

        it 'returns false' do
          profile # Ensure profile is created
          customer.reload
          expect(customer.unable_person?).to be false
        end
      end

      context 'when profile_customer does not exist' do
        it 'returns false' do
          expect(customer.unable_person?).to be_falsey
        end
      end
    end
  end

  describe 'soft delete functionality' do
    let(:customer) { create(:customer) }

    it 'soft deletes the record' do
      customer.destroy
      expect(customer.deleted_at).to be_present
      expect(Customer.with_deleted.find(customer.id)).to eq(customer)
    end

    it 'excludes soft deleted records from default scope' do
      customer.destroy
      expect(Customer.where(id: customer.id)).to be_empty
    end

    it 'includes soft deleted records with with_deleted scope' do
      customer.destroy
      expect(Customer.with_deleted.where(id: customer.id)).not_to be_empty
    end
  end

  describe 'alias attributes' do
    let(:customer) { create(:customer, email: 'test@example.com') }

    it 'aliases access_email to email' do
      expect(customer.access_email).to eq('test@example.com')
    end

    it 'allows setting email through access_email' do
      customer.access_email = 'new@example.com'
      expect(customer.email).to eq('new@example.com')
    end
  end
end
