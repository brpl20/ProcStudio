# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Team, type: :model do
  describe 'validations' do
    subject { build(:team) }
    
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:subdomain) }
    it { should validate_uniqueness_of(:subdomain).case_insensitive }
    it { should validate_length_of(:name).is_at_least(2).is_at_most(100) }
    it { should validate_length_of(:subdomain).is_at_least(3).is_at_most(50) }
    it { should validate_inclusion_of(:status).in_array(%w[active inactive suspended]) }

    describe 'subdomain format' do
      it 'allows valid subdomains' do
        valid_subdomains = %w[abc abc123 abc-def a1b2c3]
        valid_subdomains.each do |subdomain|
          team = build(:team, subdomain: subdomain)
          expect(team).to be_valid, "#{subdomain} should be valid"
        end
      end

      it 'rejects invalid subdomains' do
        invalid_subdomains = ['ab', 'abc-', '-abc', 'abc--def', 'abc_def']
        invalid_subdomains.each do |subdomain|
          team = build(:team, subdomain: subdomain)
          expect(team).not_to be_valid, "#{subdomain} should be invalid"
        end
      end
      
      it 'normalizes uppercase letters in subdomain before validation' do
        team = build(:team, subdomain: 'ABC')
        team.valid? # Trigger validation and callbacks
        expect(team.subdomain).to eq('abc') # should be normalized to lowercase
        expect(team).to be_valid
      end
    end
  end

  describe 'associations' do
    it { should belong_to(:main_admin).class_name('Admin') }
    it { should belong_to(:owner_admin).class_name('Admin') }
    it { should have_many(:team_memberships).dependent(:destroy) }
    it { should have_many(:admins).through(:team_memberships) }
    it { should have_many(:offices).dependent(:restrict_with_exception) }
    it { should have_many(:works).through(:offices) }
    it { should have_many(:subscriptions).dependent(:destroy) }
  end

  describe 'scopes' do
    let!(:active_team) { create(:team, status: 'active') }
    let!(:inactive_team) { create(:team, status: 'inactive') }

    describe '.active' do
      it 'returns only active teams' do
        expect(Team.active).to include(active_team)
        expect(Team.active).not_to include(inactive_team)
      end
    end

    describe '.by_subdomain' do
      it 'finds team by subdomain' do
        expect(Team.by_subdomain(active_team.subdomain)).to include(active_team)
        expect(Team.by_subdomain('nonexistent')).to be_empty
      end
    end
  end

  describe 'callbacks' do
    describe 'normalize_subdomain' do
      it 'normalizes subdomain to lowercase' do
        team = create(:team, subdomain: 'MyTeam')
        expect(team.subdomain).to eq('myteam')
      end

      it 'strips whitespace from subdomain' do
        team = create(:team, subdomain: ' myteam ')
        expect(team.subdomain).to eq('myteam')
      end
    end
  end

  describe 'instance methods' do
    let(:team) { create(:team) }
    let(:admin) { create(:admin) }
    let!(:membership) { create(:team_membership, team: team, admin: admin, role: 'admin') }

    describe '#active?' do
      it 'returns true for active teams' do
        team.update(status: 'active')
        expect(team.active?).to be true
      end

      it 'returns false for inactive teams' do
        team.update(status: 'inactive')
        expect(team.active?).to be false
      end
    end

    describe '#subscription' do
      it 'returns the active subscription' do
        subscription = create(:subscription, :active, team: team)
        expect(team.subscription).to eq(subscription)
      end

      it 'returns nil when no active subscription' do
        expect(team.subscription).to be_nil
      end
    end

    describe '#can_add_users?' do
      context 'with subscription' do
        let!(:subscription) { create(:subscription, :active, team: team) }

        it 'returns true when under limit' do
          expect(team.can_add_users?).to be true
        end

        it 'returns false when at limit' do
          # Create enough admins to reach the limit
          limit = subscription.subscription_plan.max_users
          (limit - 1).times { create(:team_membership, team: team) }
          
          expect(team.can_add_users?).to be false
        end
      end

      context 'without subscription' do
        it 'returns true' do
          expect(team.can_add_users?).to be true
        end
      end
    end

    describe '#can_add_offices?' do
      context 'with subscription' do
        let!(:subscription) { create(:subscription, :active, team: team) }

        it 'returns true when under limit' do
          expect(team.can_add_offices?).to be true
        end

        it 'returns false when at limit' do
          limit = subscription.subscription_plan.max_offices
          create_list(:office, limit, team: team)
          
          expect(team.can_add_offices?).to be false
        end
      end

      context 'without subscription' do
        it 'returns true' do
          expect(team.can_add_offices?).to be true
        end
      end
    end

    describe '#admin_role' do
      it 'returns the admin role in the team' do
        expect(team.admin_role(admin)).to eq('admin')
      end

      it 'returns nil for non-members' do
        other_admin = create(:admin)
        expect(team.admin_role(other_admin)).to be_nil
      end
    end

    describe '#owner?' do
      it 'returns true for team owner' do
        expect(team.owner?(team.owner_admin)).to be true
      end

      it 'returns false for non-owner' do
        expect(team.owner?(admin)).to be false
      end
    end

    describe '#admin?' do
      it 'returns true for owner' do
        expect(team.admin?(team.owner_admin)).to be true
      end

      it 'returns true for admin role' do
        expect(team.admin?(admin)).to be true
      end

      it 'returns false for member role' do
        membership.update(role: 'member')
        expect(team.admin?(admin)).to be false
      end
    end

    describe '#member?' do
      it 'returns true for team members' do
        expect(team.member?(admin)).to be true
      end

      it 'returns false for non-members' do
        other_admin = create(:admin)
        expect(team.member?(other_admin)).to be false
      end
    end
  end
end