# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::Invitations::AcceptanceService do
  let(:team) { create(:team) }
  let(:inviter) { create(:user, team: team) }
  let(:invitation) { create(:user_invitation, email: 'newuser@example.com', invited_by: inviter, team: team) }

  let(:user_params) do
    {
      password: 'password123',
      password_confirmation: 'password123',
      user_profile_attributes: {
        name: 'João',
        last_name: 'Silva',
        oab: '123456'
      }
    }
  end

  describe '.accept_invitation' do
    context 'with valid invitation and user params' do
      it 'creates user successfully' do
        result = described_class.accept_invitation(
          token: invitation.token,
          user_params: user_params
        )

        expect(result.success?).to be true
        expect(User.find_by(email: 'newuser@example.com')).to be_present
      end

      it 'assigns user to invitation team' do
        result = described_class.accept_invitation(
          token: invitation.token,
          user_params: user_params
        )

        expect(result.success?).to be true
        user = User.find_by(email: 'newuser@example.com')
        expect(user.team).to eq(team)
      end

      it 'creates user profile with correct role' do
        result = described_class.accept_invitation(
          token: invitation.token,
          user_params: user_params
        )

        expect(result.success?).to be true
        user = User.find_by(email: 'newuser@example.com')
        expect(user.user_profile.role).to eq('lawyer')
        expect(user.user_profile.name).to eq('João')
        expect(user.user_profile.last_name).to eq('Silva')
      end

      it 'marks invitation as accepted' do
        result = described_class.accept_invitation(
          token: invitation.token,
          user_params: user_params
        )

        expect(result.success?).to be true
        invitation.reload
        expect(invitation.status).to eq('accepted')
        expect(invitation.accepted_at).to be_present
      end

      it 'returns user data in response' do
        result = described_class.accept_invitation(
          token: invitation.token,
          user_params: user_params
        )

        expect(result.success?).to be true
        expect(result.data[:user][:email]).to eq('newuser@example.com')
        expect(result.data[:user][:team_id]).to eq(team.id)
        expect(result.data[:invitation][:invited_by][:id]).to eq(inviter.id)
      end
    end

    context 'with invalid token' do
      it 'returns error' do
        result = described_class.accept_invitation(
          token: 'invalid-token',
          user_params: user_params
        )

        expect(result.success?).to be false
        expect(result.errors).to include('Convite não encontrado')
      end
    end

    context 'with expired invitation' do
      let(:expired_invitation) { create(:user_invitation, :expired, email: 'expired@example.com', invited_by: inviter, team: team) }

      it 'returns error' do
        result = described_class.accept_invitation(
          token: expired_invitation.token,
          user_params: user_params
        )

        expect(result.success?).to be false
        expect(result.errors).to include(match(/expirou/))
      end
    end

    context 'with already accepted invitation' do
      let(:accepted_invitation) { create(:user_invitation, :accepted, email: 'accepted@example.com', invited_by: inviter, team: team) }

      it 'returns error' do
        result = described_class.accept_invitation(
          token: accepted_invitation.token,
          user_params: user_params
        )

        expect(result.success?).to be false
        expect(result.errors).to include(match(/já foi aceito/))
      end
    end

    context 'with existing user email' do
      it 'returns error when user registers after invitation was sent' do
        # Create invitation first
        other_invitation = create(:user_invitation, email: 'existing@example.com', invited_by: inviter, team: team)
        # Then create user with same email (simulating someone registering independently)
        create(:user, email: 'existing@example.com', team: team)

        result = described_class.accept_invitation(
          token: other_invitation.token,
          user_params: user_params
        )

        expect(result.success?).to be false
        expect(result.errors).to include(match(/já está cadastrado/))
      end
    end

    context 'with invalid user params' do
      let(:invalid_params) do
        {
          password: 'short',
          password_confirmation: 'different',
          user_profile_attributes: { name: 'João' }
        }
      end

      it 'returns validation errors' do
        result = described_class.accept_invitation(
          token: invitation.token,
          user_params: invalid_params
        )

        expect(result.success?).to be false
        expect(result.errors).to be_present
      end

      it 'does not mark invitation as accepted' do
        result = described_class.accept_invitation(
          token: invitation.token,
          user_params: invalid_params
        )

        expect(result.success?).to be false
        invitation.reload
        expect(invitation.status).to eq('pending')
      end
    end

    context 'with minimal user profile data' do
      let(:minimal_params) do
        {
          password: 'password123',
          password_confirmation: 'password123',
          user_profile_attributes: {
            name: 'João',
            oab: '123456'
          }
        }
      end

      it 'creates user with minimal data' do
        result = described_class.accept_invitation(
          token: invitation.token,
          user_params: minimal_params
        )

        expect(result.success?).to be true
        user = User.find_by(email: 'newuser@example.com')
        expect(user.user_profile.name).to eq('João')
        expect(user.user_profile.last_name).to be_nil
      end
    end
  end
end
