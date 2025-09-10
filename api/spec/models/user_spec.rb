# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  deleted_at             :datetime
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  jwt_token              :string
#  oab                    :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  status                 :string           default("active"), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  team_id                :bigint           not null
#
# Indexes
#
#  index_users_on_deleted_at            (deleted_at)
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_jwt_token             (jwt_token) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_team_id               (team_id)
#
# Foreign Keys
#
#  fk_rails_...  (team_id => teams.id)
#
require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should belong_to(:team) }
    it { should have_one(:user_profile).dependent(:destroy) }
  end

  describe 'validations' do
    subject { build(:user) }

    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_presence_of(:password) }
    it { should validate_length_of(:password).is_at_least(6) }
  end

  describe 'enums' do
    it 'defines status enum' do
      expect(User.statuses).to eq({ 'active' => 'active', 'inactive' => 'inactive' })
    end
  end

  describe 'devise modules' do
    it 'includes database_authenticatable module' do
      expect(User.devise_modules).to include(:database_authenticatable)
    end

    it 'includes registerable module' do
      expect(User.devise_modules).to include(:registerable)
    end

    it 'includes recoverable module' do
      expect(User.devise_modules).to include(:recoverable)
    end

    it 'includes rememberable module' do
      expect(User.devise_modules).to include(:rememberable)
    end

    it 'includes validatable module' do
      expect(User.devise_modules).to include(:validatable)
    end
  end

  describe 'nested attributes' do
    it { should accept_nested_attributes_for(:user_profile) }

    context 'when rejecting blank attributes' do
      let(:user) { build(:user) }

      it 'rejects empty user_profile attributes' do
        user_attributes = {
          email: 'test@example.com',
          password: 'password123',
          team_id: create(:team).id,
          user_profile_attributes: { name: '', last_name: '' }
        }

        user = User.new(user_attributes)
        expect(user.user_profile).to be_nil
      end

      it 'accepts non-empty user_profile attributes' do
        team = create(:team)
        user_attributes = {
          email: 'test@example.com',
          password: 'password123',
          team_id: team.id,
          user_profile_attributes: { name: 'John', last_name: 'Doe' }
        }

        user = User.create(user_attributes)
        expect(user.user_profile).to be_present
        expect(user.user_profile.name).to eq('John')
      end
    end
  end

  describe 'delegations' do
    let(:user) { create(:user) }

    context 'when user_profile exists' do
      let!(:user_profile) { create(:user_profile, user: user, role: 'admin') }

      it 'delegates role to user_profile' do
        expect(user.role).to eq('admin')
      end
    end

    context 'when user_profile does not exist' do
      it 'returns nil for role' do
        expect(user.role).to be_nil
      end
    end
  end

  describe 'alias attributes' do
    let(:user) { create(:user, email: 'test@example.com') }

    it 'aliases access_email to email' do
      expect(user.access_email).to eq('test@example.com')
    end

    it 'allows setting email through access_email' do
      user.access_email = 'new@example.com'
      expect(user.email).to eq('new@example.com')
    end
  end

  describe 'callbacks' do
    describe 'before_destroy' do
      let(:user) { create(:user) }
      let(:another_user) { create(:user) }
      let(:customer) { create(:customer) }

      before do
        # Create associated records by updating created_by_id directly
        Customer.where(id: customer.id).update_all(created_by_id: user.id) # rubocop:disable Rails/SkipsModelValidations
      end

      it 'nullifies created_by_id in Customer records' do
        expect(Customer.where(created_by_id: user.id).count).to eq(1)
        user.destroy
        expect(Customer.where(created_by_id: user.id).count).to eq(0)
        expect(Customer.where(created_by_id: nil).count).to be >= 1
      end

      it 'does not affect records created by other users' do
        Customer.where(id: customer.id).update_all(created_by_id: another_user.id) # rubocop:disable Rails/SkipsModelValidations
        user.destroy
        expect(Customer.where(created_by_id: another_user.id).count).to eq(1)
      end
    end
  end

  describe 'soft delete functionality' do
    let(:user) { create(:user) }

    it 'soft deletes the record' do
      user.destroy
      expect(user.deleted_at).to be_present
      expect(User.with_deleted.find(user.id)).to eq(user)
    end

    it 'excludes soft deleted records from default scope' do
      user.destroy
      expect(User.where(id: user.id)).to be_empty
    end

    it 'includes soft deleted records with with_deleted scope' do
      user.destroy
      expect(User.with_deleted.where(id: user.id)).not_to be_empty
    end

    it 'restores soft deleted records' do
      user.destroy
      expect(user.deleted_at).to be_present

      user.recover
      expect(user.deleted_at).to be_nil
      expect(User.find(user.id)).to eq(user)
    end
  end

  describe 'JWT token' do
    let(:user) { create(:user) }

    it 'can store JWT token' do
      token = 'sample.jwt.token'
      user.update(jwt_token: token)
      expect(user.reload.jwt_token).to eq(token)
    end

    it 'generates JWT token after creation in factory' do
      new_user = create(:user)
      expect(new_user.jwt_token).to be_present

      # Verify token structure
      decoded_token = JWT.decode(
        new_user.jwt_token,
        Rails.application.secret_key_base,
        true,
        algorithm: 'HS256'
      )

      expect(decoded_token[0]['user_id']).to eq(new_user.id)
    end
  end

  describe 'status management' do
    let(:user) { create(:user) }

    it 'defaults to active status' do
      new_user = User.new(email: 'test@example.com', password: 'password', team: create(:team))
      expect(new_user.status).to eq('active')
    end

    it 'can be set to inactive' do
      user.inactive!
      expect(user.reload.status).to eq('inactive')
    end

    it 'can be set back to active' do
      user.inactive!
      user.active!
      expect(user.reload.status).to eq('active')
    end
  end

  describe 'OAB field' do
    let(:user) { create(:user, oab: '123456') }

    it 'stores OAB number' do
      expect(user.oab).to eq('123456')
    end

    it 'can be updated' do
      user.update(oab: '789012')
      expect(user.reload.oab).to eq('789012')
    end
  end
end
