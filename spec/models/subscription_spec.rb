# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Subscription, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:start_date) }
    it { should validate_inclusion_of(:status).in_array(%w[trial active inactive cancelled expired suspended]) }
  end

  describe 'associations' do
    it { should belong_to(:team) }
    it { should belong_to(:subscription_plan) }
    it { should have_many(:payment_transactions).dependent(:destroy) }
  end

  describe 'scopes' do
    let!(:active_subscription) { create(:subscription, :active) }
    let!(:trial_subscription) { create(:subscription, status: 'trial') }
    let!(:cancelled_subscription) { create(:subscription, :cancelled) }

    describe '.active' do
      it 'returns active subscriptions' do
        expect(Subscription.active).to include(active_subscription)
        expect(Subscription.active).not_to include(trial_subscription)
      end
    end

    describe '.trial' do
      it 'returns trial subscriptions' do
        expect(Subscription.trial).to include(trial_subscription)
        expect(Subscription.trial).not_to include(active_subscription)
      end
    end

    describe '.cancelled' do
      it 'returns cancelled subscriptions' do
        expect(Subscription.cancelled).to include(cancelled_subscription)
        expect(Subscription.cancelled).not_to include(active_subscription)
      end
    end
  end

  describe 'callbacks' do
    let(:subscription_plan) { create(:subscription_plan) }

    describe 'set_trial_end_date' do
      it 'sets trial end date for trial subscriptions' do
        subscription = create(:subscription, status: 'trial', subscription_plan: subscription_plan)
        expected_date = subscription.start_date + subscription_plan.trial_days.days
        expect(subscription.trial_end_date).to eq(expected_date)
      end

      it 'does not set trial end date for non-trial subscriptions' do
        subscription = create(:subscription, :active, subscription_plan: subscription_plan)
        expect(subscription.trial_end_date).to be_nil
      end
    end

    describe 'calculate_monthly_amount' do
      it 'sets monthly amount for monthly plans' do
        plan = create(:subscription_plan, billing_interval: 'monthly', price: 100)
        subscription = create(:subscription, subscription_plan: plan)
        expect(subscription.monthly_amount).to eq(100)
      end

      it 'calculates monthly amount for yearly plans' do
        plan = create(:subscription_plan, billing_interval: 'yearly', price: 1200)
        subscription = create(:subscription, subscription_plan: plan)
        expect(subscription.monthly_amount).to eq(100)
      end
    end
  end

  describe 'instance methods' do
    let(:subscription) { create(:subscription, :trial) }

    describe 'status check methods' do
      it 'returns correct status for trial' do
        expect(subscription.trial?).to be true
        expect(subscription.active?).to be false
      end

      it 'returns correct status for active' do
        subscription.update(status: 'active')
        expect(subscription.active?).to be true
        expect(subscription.trial?).to be false
      end
    end

    describe '#trial_expired?' do
      it 'returns true when trial has expired' do
        subscription.update(trial_end_date: 1.day.ago)
        expect(subscription.trial_expired?).to be true
      end

      it 'returns false when trial has not expired' do
        subscription.update(trial_end_date: 1.day.from_now)
        expect(subscription.trial_expired?).to be false
      end

      it 'returns false for non-trial subscriptions' do
        subscription.update(status: 'active')
        expect(subscription.trial_expired?).to be false
      end
    end

    describe '#subscription_expired?' do
      it 'returns true when subscription has expired' do
        subscription.update(end_date: 1.day.ago)
        expect(subscription.subscription_expired?).to be true
      end

      it 'returns false when subscription has not expired' do
        subscription.update(end_date: 1.day.from_now)
        expect(subscription.subscription_expired?).to be false
      end

      it 'returns false when no end date' do
        expect(subscription.subscription_expired?).to be false
      end
    end

    describe '#days_until_expiry' do
      it 'returns days until expiry' do
        subscription.update(end_date: 5.days.from_now)
        expect(subscription.days_until_expiry).to eq(5)
      end

      it 'returns nil when no end date' do
        expect(subscription.days_until_expiry).to be_nil
      end
    end

    describe '#trial_days_remaining' do
      it 'returns remaining trial days' do
        subscription.update(trial_end_date: 3.days.from_now)
        expect(subscription.trial_days_remaining).to eq(3)
      end

      it 'returns 0 when trial has expired' do
        subscription.update(trial_end_date: 1.day.ago)
        expect(subscription.trial_days_remaining).to eq(0)
      end

      it 'returns 0 for non-trial subscriptions' do
        subscription.update(status: 'active')
        expect(subscription.trial_days_remaining).to eq(0)
      end
    end

    describe '#can_access_feature?' do
      let(:plan) { create(:subscription_plan, features: { 'reports' => true, 'api_access' => false }) }
      let(:subscription) { create(:subscription, :active, subscription_plan: plan) }

      it 'returns true for enabled features' do
        expect(subscription.can_access_feature?(:reports)).to be true
      end

      it 'returns false for disabled features' do
        expect(subscription.can_access_feature?(:api_access)).to be false
      end

      it 'returns false for inactive subscriptions' do
        subscription.update(status: 'inactive')
        expect(subscription.can_access_feature?(:reports)).to be false
      end
    end

    describe '#usage_percentage' do
      let(:team) { create(:team, :with_subscription) }
      let(:subscription) { team.subscription }

      before do
        create_list(:team_membership, 2, team: team)
        create_list(:office, 1, team: team)
      end

      it 'calculates user usage percentage' do
        # Team has 2 additional members + owner/main admin = 3 total
        expected_percentage = (3.0 / subscription.subscription_plan.max_users * 100).round(1)
        expect(subscription.usage_percentage(:users)).to eq(expected_percentage)
      end

      it 'calculates office usage percentage' do
        expected_percentage = (1.0 / subscription.subscription_plan.max_offices * 100).round(1)
        expect(subscription.usage_percentage(:offices)).to eq(expected_percentage)
      end

      it 'returns 0 for unknown resource types' do
        expect(subscription.usage_percentage(:unknown)).to eq(0)
      end
    end

    describe '#next_billing_date' do
      let(:subscription) { create(:subscription, :active, start_date: Date.current) }

      it 'calculates next billing date for monthly plans' do
        subscription.subscription_plan.update(billing_interval: 'monthly')
        expected_date = Date.current + 1.month
        expect(subscription.next_billing_date).to eq(expected_date)
      end

      it 'calculates next billing date for yearly plans' do
        subscription.subscription_plan.update(billing_interval: 'yearly')
        expected_date = Date.current + 1.year
        expect(subscription.next_billing_date).to eq(expected_date)
      end

      it 'returns nil for inactive subscriptions' do
        subscription.update(status: 'inactive')
        expect(subscription.next_billing_date).to be_nil
      end
    end
  end
end