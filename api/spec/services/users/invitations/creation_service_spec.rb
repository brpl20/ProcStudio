# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::Invitations::CreationService do
  let(:team) { create(:team) }
  let(:user) { create(:user, team: team) }
  let(:base_url) { 'http://localhost:5173' }

  describe '.create_invitations' do
    context 'with valid emails' do
      let(:emails) { ['user1@example.com', 'user2@example.com'] }

      it 'creates invitations successfully' do
        result = described_class.create_invitations(
          emails: emails,
          current_user: user,
          base_url: base_url
        )

        expect(result.success?).to be true
        expect(result.data[:summary][:successful_count]).to eq(2)
        expect(result.data[:summary][:failed_count]).to eq(0)
        expect(UserInvitation.count).to eq(2)
      end

      it 'sends invitation emails' do
        allow_any_instance_of(Users::Mail::InvitationService).to receive(:call)

        result = described_class.create_invitations(
          emails: emails,
          current_user: user,
          base_url: base_url
        )

        expect(result.success?).to be true
      end

      it 'assigns invitations to current user team' do
        result = described_class.create_invitations(
          emails: emails,
          current_user: user,
          base_url: base_url
        )

        expect(result.success?).to be true
        UserInvitation.all.each do |invitation|
          expect(invitation.team).to eq(user.team)
          expect(invitation.invited_by).to eq(user)
        end
      end
    end

    context 'with duplicate emails' do
      let(:emails) { ['user1@example.com', 'user1@example.com', 'user2@example.com'] }

      it 'removes duplicates and creates unique invitations' do
        result = described_class.create_invitations(
          emails: emails,
          current_user: user,
          base_url: base_url
        )

        expect(result.success?).to be true
        expect(result.data[:summary][:successful_count]).to eq(2)
        expect(UserInvitation.count).to eq(2)
      end
    end

    context 'with invalid emails' do
      let(:emails) { ['invalid-email', 'valid@example.com'] }

      it 'returns error for invalid emails' do
        result = described_class.create_invitations(
          emails: emails,
          current_user: user,
          base_url: base_url
        )

        expect(result.success?).to be false
        expect(result.errors).to include(match(/E-mails inválidos/))
      end
    end

    context 'with already registered email' do
      let!(:existing_user) { create(:user, email: 'existing@example.com', team: team) }
      let(:emails) { ['existing@example.com', 'new@example.com'] }

      it 'fails for registered email and succeeds for new email' do
        result = described_class.create_invitations(
          emails: emails,
          current_user: user,
          base_url: base_url
        )

        expect(result.success?).to be false
        expect(result.data[:summary][:successful_count]).to eq(1)
        expect(result.data[:summary][:failed_count]).to eq(1)
        expect(result.data[:failed].first[:email]).to eq('existing@example.com')
      end
    end

    context 'with pending invitation' do
      let!(:existing_invitation) { create(:user_invitation, email: 'pending@example.com', team: team, invited_by: user) }
      let(:emails) { ['pending@example.com', 'new@example.com'] }

      it 'fails for email with pending invitation' do
        result = described_class.create_invitations(
          emails: emails,
          current_user: user,
          base_url: base_url
        )

        expect(result.success?).to be false
        expect(result.data[:summary][:successful_count]).to eq(1)
        expect(result.data[:summary][:failed_count]).to eq(1)
      end
    end

    context 'with too many invitations' do
      let(:emails) { (1..51).map { |i| "user#{i}@example.com" } }

      it 'returns error when exceeding limit' do
        result = described_class.create_invitations(
          emails: emails,
          current_user: user,
          base_url: base_url
        )

        expect(result.success?).to be false
        expect(result.errors).to include(match(/Máximo de 50 convites/))
      end
    end

    context 'with empty emails' do
      let(:emails) { [] }

      it 'returns error' do
        result = described_class.create_invitations(
          emails: emails,
          current_user: user,
          base_url: base_url
        )

        expect(result.success?).to be false
        expect(result.errors).to include('Nenhum e-mail fornecido')
      end
    end

    context 'with email normalization' do
      let(:emails) { ['  USER@EXAMPLE.COM  ', 'user2@example.com'] }

      it 'normalizes emails (lowercase and trim)' do
        result = described_class.create_invitations(
          emails: emails,
          current_user: user,
          base_url: base_url
        )

        expect(result.success?).to be true
        invitation = UserInvitation.find_by(email: 'user@example.com')
        expect(invitation).to be_present
      end
    end
  end
end
