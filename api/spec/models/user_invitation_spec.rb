# frozen_string_literal: true

# == Schema Information
#
# Table name: user_invitations
#
#  id            :bigint           not null, primary key
#  accepted_at   :datetime
#  deleted_at    :datetime
#  email         :string           not null
#  expires_at    :datetime         not null
#  metadata      :jsonb
#  status        :string           default("pending"), not null
#  token         :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  invited_by_id :bigint           not null
#  team_id       :bigint           not null
#
# Indexes
#
#  index_user_invitations_on_deleted_at                    (deleted_at)
#  index_user_invitations_on_email                         (email)
#  index_user_invitations_on_email_and_team_id_and_status  (email,team_id,status)
#  index_user_invitations_on_invited_by_id                 (invited_by_id)
#  index_user_invitations_on_status                        (status)
#  index_user_invitations_on_team_id                       (team_id)
#  index_user_invitations_on_token                         (token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (invited_by_id => users.id)
#  fk_rails_...  (team_id => teams.id)
#
require 'rails_helper'

RSpec.describe UserInvitation, type: :model do
  describe 'associations' do
    it { should belong_to(:invited_by).class_name('User') }
    it { should belong_to(:team) }
  end

  describe 'validations' do
    it { should validate_presence_of(:email) }
    # Token and expires_at are auto-generated, so we test them differently
    it { should validate_presence_of(:status) }

    describe 'email format validation' do
      let(:team) { create(:team) }
      let(:user) { create(:user, team: team) }

      it 'validates email format' do
        invitation = build(:user_invitation, email: 'invalid-email', invited_by: user, team: team)
        expect(invitation).not_to be_valid
        expect(invitation.errors[:email]).to be_present
      end

      it 'accepts valid email' do
        invitation = build(:user_invitation, email: 'valid@example.com', invited_by: user, team: team)
        expect(invitation).to be_valid
      end
    end

    describe 'email uniqueness validation' do
      let(:team) { create(:team) }
      let(:user) { create(:user, team: team) }

      context 'when email is already registered' do
        it 'is invalid' do
          existing_user = create(:user, email: 'existing@example.com', team: team)
          invitation = build(:user_invitation, email: existing_user.email, invited_by: user, team: team)

          expect(invitation).not_to be_valid
          expect(invitation.errors[:email]).to include('já está cadastrado na plataforma')
        end
      end

      context 'when pending invitation exists for email' do
        it 'is invalid' do
          create(:user_invitation, email: 'invited@example.com', team: team, invited_by: user)
          new_invitation = build(:user_invitation, email: 'invited@example.com', team: team, invited_by: user)

          expect(new_invitation).not_to be_valid
          expect(new_invitation.errors[:email]).to include('já possui um convite pendente')
        end
      end
    end
  end

  describe 'callbacks' do
    let(:team) { create(:team) }
    let(:user) { create(:user, team: team) }

    describe 'token generation' do
      it 'generates token before validation' do
        invitation = build(:user_invitation, token: nil, invited_by: user, team: team)
        invitation.valid?
        expect(invitation.token).to be_present
      end

      it 'does not override existing token' do
        invitation = build(:user_invitation, token: 'existing-token', invited_by: user, team: team)
        invitation.valid?
        expect(invitation.token).to eq('existing-token')
      end
    end

    describe 'expiration setting' do
      it 'sets expiration to 7 days from now' do
        invitation = create(:user_invitation, invited_by: user, team: team)
        expect(invitation.expires_at).to be_within(1.second).of(7.days.from_now)
      end
    end
  end

  describe 'scopes' do
    let(:team) { create(:team) }
    let(:user) { create(:user, team: team) }

    describe '.pending' do
      it 'returns only pending invitations' do
        pending_inv = create(:user_invitation, status: :pending, invited_by: user, team: team)
        create(:user_invitation, status: :accepted, invited_by: user, team: team)

        expect(UserInvitation.pending).to eq([pending_inv])
      end
    end

    describe '.not_expired' do
      it 'returns only non-expired invitations' do
        valid_inv = create(:user_invitation, expires_at: 1.day.from_now, invited_by: user, team: team)
        create(:user_invitation, expires_at: 1.day.ago, invited_by: user, team: team)

        expect(UserInvitation.not_expired).to eq([valid_inv])
      end
    end

    describe '.valid_invitations' do
      it 'returns pending and non-expired invitations' do
        valid_inv = create(:user_invitation, status: :pending, expires_at: 1.day.from_now, invited_by: user, team: team)
        create(:user_invitation, status: :accepted, expires_at: 1.day.from_now, invited_by: user, team: team)
        create(:user_invitation, status: :pending, expires_at: 1.day.ago, invited_by: user, team: team)

        expect(UserInvitation.valid_invitations).to eq([valid_inv])
      end
    end
  end

  describe 'instance methods' do
    let(:team) { create(:team) }
    let(:user) { create(:user, team: team) }

    describe '#expired?' do
      it 'returns true if invitation is expired' do
        invitation = create(:user_invitation, expires_at: 1.day.ago, invited_by: user, team: team)
        expect(invitation.expired?).to be true
      end

      it 'returns false if invitation is not expired' do
        invitation = create(:user_invitation, expires_at: 1.day.from_now, invited_by: user, team: team)
        expect(invitation.expired?).to be false
      end
    end

    describe '#valid_for_acceptance?' do
      it 'returns true for pending and non-expired invitation' do
        invitation = create(:user_invitation, status: :pending, expires_at: 1.day.from_now, invited_by: user, team: team)
        expect(invitation.valid_for_acceptance?).to be true
      end

      it 'returns false for expired invitation' do
        invitation = create(:user_invitation, status: :pending, expires_at: 1.day.ago, invited_by: user, team: team)
        expect(invitation.valid_for_acceptance?).to be false
      end

      it 'returns false for accepted invitation' do
        invitation = create(:user_invitation, status: :accepted, expires_at: 1.day.from_now, invited_by: user, team: team)
        expect(invitation.valid_for_acceptance?).to be false
      end
    end

    describe '#mark_as_accepted!' do
      it 'updates status to accepted and sets accepted_at' do
        invitation = create(:user_invitation, invited_by: user, team: team)
        invitation.mark_as_accepted!

        expect(invitation.status).to eq('accepted')
        expect(invitation.accepted_at).to be_present
      end
    end

    describe '#mark_as_expired!' do
      it 'updates status to expired' do
        invitation = create(:user_invitation, invited_by: user, team: team)
        invitation.mark_as_expired!

        expect(invitation.status).to eq('expired')
      end
    end

    describe '#days_until_expiration' do
      it 'returns days until expiration' do
        invitation = create(:user_invitation, expires_at: 3.days.from_now, invited_by: user, team: team)
        expect(invitation.days_until_expiration).to eq(3)
      end

      it 'returns 0 for expired invitations' do
        invitation = create(:user_invitation, expires_at: 1.day.ago, invited_by: user, team: team)
        expect(invitation.days_until_expiration).to eq(0)
      end
    end
  end
end
