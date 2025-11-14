# Subscription & Referral System - Implementation Guide

## Overview
Complete subscription management with Stripe integration and referral reward system.

## System Architecture

### Plans
1. **Basic Plan** (Free)
   - 1 user (free)
   - 100 customers, 150 jobs, 100 works
   - 100 document generations (lifetime total)
   - Extra users: R$ 15/month each
   - Base price: R$ 0

2. **Pro Plan**
   - 1 user (included)
   - 1 office, 2 lawyers
   - Unlimited customers, jobs, works
   - 100 documents/month (resets monthly)
   - Extra users: R$ 15/month each
   - Base price: R$ 70/month

### Referral Rewards
- **Only Pro plan subscriptions earn rewards**
- Reward: Referrer gets +1 free month when referred user subscribes to Pro

---

## Implementation Status

### ✅ Completed

#### Database Schema
- [x] `subscriptions` table - Team subscriptions with Stripe data
- [x] `referral_invitations` table - Marketing referrals tracking
- [x] `usage_limits` table - Track resource usage per team

#### Models
- [x] `Subscription` model with plan limits and Stripe integration
- [x] `ReferralInvitation` model with reward tracking
- [x] `UsageLimit` model with usage tracking
- [x] Updated `Team` model with subscription associations
- [x] Updated `User` model with referral associations

#### Dependencies
- [x] Stripe gem installed (`stripe ~> 12.0`)
- [x] Stripe initializer configured
- [x] ENV variables added for Stripe credentials

---

## 🚧 To Be Implemented

### 1. Stripe Integration Services

#### `app/services/stripe/customer_service.rb`
```ruby
# Create/retrieve Stripe customer for team
# Methods: create_customer, find_or_create_customer
```

#### `app/services/stripe/subscription_service.rb`
```ruby
# Manage Stripe subscriptions
# Methods: create_subscription, update_subscription, cancel_subscription
```

#### `app/services/stripe/webhook_handler.rb`
```ruby
# Handle Stripe webhooks
# Events: checkout.session.completed, customer.subscription.updated,
#         customer.subscription.deleted, invoice.payment_succeeded,
#         invoice.payment_failed
```

---

### 2. Subscription Management Services

#### `app/services/subscriptions/creation_service.rb`
```ruby
# Create team subscription (Basic by default)
# Initialize usage limits
# Create Stripe customer if Pro plan
```

#### `app/services/subscriptions/upgrade_service.rb`
```ruby
# Upgrade from Basic to Pro
# Create Stripe subscription
# Handle referral conversion if applicable
```

#### `app/services/subscriptions/cancellation_service.rb`
```ruby
# Cancel Pro subscription
# Downgrade to Basic
# Cancel Stripe subscription
```

#### `app/services/subscriptions/extra_user_service.rb`
```ruby
# Add/remove extra users
# Update Stripe subscription quantity
```

---

### 3. Referral System Services

#### `app/services/referrals/creation_service.rb`
```ruby
# Send referral invitations
# Similar to UserInvitationService but for public referrals
# Email with referral link
```

#### `app/services/referrals/acceptance_service.rb`
```ruby
# Accept referral and create new team + user
# Mark referral as accepted
# Wait for Pro subscription to convert
```

#### `app/services/referrals/conversion_service.rb`
```ruby
# Mark referral as converted when Pro subscription created
# Award +1 free month to referrer
# Triggered by subscription upgrade
```

#### `app/services/referrals/mail/referral_email_service.rb`
```ruby
# Send referral invitation email via Mailjet
# Include referral token and benefits description
```

---

### 4. Usage Tracking Services

#### `app/services/usage/tracker_service.rb`
```ruby
# Track resource creation/deletion
# Methods: track_customer, track_job, track_work, track_document
# Increment/decrement usage counters
```

#### `app/services/usage/limit_checker_service.rb`
```ruby
# Check if team is within plan limits
# Return true/false and usage percentage
# Used in before_create callbacks
```

#### `app/services/usage/monthly_reset_service.rb`
```ruby
# Reset monthly document counter for Pro plans
# Run via Sidekiq cron job (1st of each month)
```

---

### 5. Controllers

#### `app/controllers/api/v1/subscriptions_controller.rb`
**Endpoints:**
- `GET /api/v1/subscriptions` - Get current team subscription
- `POST /api/v1/subscriptions/upgrade` - Upgrade to Pro
- `DELETE /api/v1/subscriptions` - Cancel subscription
- `POST /api/v1/subscriptions/extra_users` - Add extra user
- `DELETE /api/v1/subscriptions/extra_users/:id` - Remove extra user
- `GET /api/v1/subscriptions/checkout_session` - Create Stripe checkout

#### `app/controllers/api/v1/referrals_controller.rb`
**Endpoints:**
- `POST /api/v1/referrals` - Send referral invitations
- `GET /api/v1/referrals/:token/verify` - Verify referral token
- `POST /api/v1/referrals/:token/accept` - Accept referral & signup
- `GET /api/v1/referrals` - List sent referrals
- `GET /api/v1/referrals/stats` - Referral stats & rewards

#### `app/controllers/api/v1/usage_controller.rb`
**Endpoints:**
- `GET /api/v1/usage` - Get current usage stats
- `GET /api/v1/usage/limits` - Get plan limits

#### `app/controllers/webhooks/stripe_controller.rb`
**Endpoints:**
- `POST /webhooks/stripe` - Handle Stripe webhooks

---

### 6. Background Jobs

#### `app/jobs/usage_monthly_reset_job.rb`
```ruby
# Reset monthly document usage for Pro plans
# Scheduled via Sidekiq Cron (every 1st of month)
```

#### `app/jobs/subscription_renewal_job.rb`
```ruby
# Process free months when subscription renews
# Decrement free_months_remaining if > 0
```

---

### 7. Concerns/Middleware

#### `app/controllers/concerns/usage_enforcement.rb`
```ruby
# Before action to check usage limits
# Prevent creation if at limit
# Include in relevant controllers (customers, jobs, works, documents)
```

#### `app/models/concerns/usage_trackable.rb`
```ruby
# Concern for models that count toward usage
# Auto-increment/decrement usage on create/destroy
# Include in Customer, Job, Work models
```

---

### 8. Mailers

#### `app/services/subscriptions/mail/upgrade_confirmation_service.rb`
```ruby
# Send email when team upgrades to Pro
```

#### `app/services/subscriptions/mail/payment_failed_service.rb`
```ruby
# Send email when payment fails
```

---

### 9. Tests (RSpec)

#### Model Tests
- [ ] `spec/models/subscription_spec.rb`
- [ ] `spec/models/referral_invitation_spec.rb`
- [ ] `spec/models/usage_limit_spec.rb`

#### Service Tests
- [ ] `spec/services/stripe/customer_service_spec.rb`
- [ ] `spec/services/stripe/subscription_service_spec.rb`
- [ ] `spec/services/subscriptions/creation_service_spec.rb`
- [ ] `spec/services/subscriptions/upgrade_service_spec.rb`
- [ ] `spec/services/referrals/creation_service_spec.rb`
- [ ] `spec/services/referrals/acceptance_service_spec.rb`
- [ ] `spec/services/referrals/conversion_service_spec.rb`
- [ ] `spec/services/usage/tracker_service_spec.rb`

#### Controller Tests
- [ ] `spec/requests/api/v1/subscriptions_spec.rb`
- [ ] `spec/requests/api/v1/referrals_spec.rb`
- [ ] `spec/requests/api/v1/usage_spec.rb`
- [ ] `spec/requests/webhooks/stripe_spec.rb`

#### Integration Tests
- [ ] Complete subscription flow (Basic → Pro → Cancel)
- [ ] Referral flow with reward
- [ ] Usage limit enforcement
- [ ] Stripe webhook handling

---

## Stripe Setup Checklist

### 1. Create Stripe Account
- [ ] Sign up at https://stripe.com
- [ ] Complete account verification
- [ ] Enable test mode for development

### 2. Create Products in Stripe Dashboard

**Pro Plan Product:**
- [ ] Product name: "Procstudio Pro"
- [ ] Create recurring price: R$ 70/month
- [ ] Copy Price ID → `STRIPE_PRICE_PRO_MONTHLY`

**Extra User Product:**
- [ ] Product name: "Extra User"
- [ ] Create recurring price: R$ 15/month
- [ ] Copy Price ID → `STRIPE_PRICE_EXTRA_USER`

### 3. Get API Keys
- [ ] Copy Secret Key → `STRIPE_SECRET_KEY`
- [ ] Copy Publishable Key → `STRIPE_PUBLISHABLE_KEY`

### 4. Set Up Webhooks
- [ ] URL: `https://yourdomain.com/webhooks/stripe`
- [ ] Events to listen to:
  - `checkout.session.completed`
  - `customer.subscription.created`
  - `customer.subscription.updated`
  - `customer.subscription.deleted`
  - `invoice.payment_succeeded`
  - `invoice.payment_failed`
- [ ] Copy Webhook Secret → `STRIPE_WEBHOOK_SECRET`

### 5. Update .env File
```bash
STRIPE_SECRET_KEY=sk_test_...
STRIPE_PUBLISHABLE_KEY=pk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...
STRIPE_PRICE_PRO_MONTHLY=price_...
STRIPE_PRICE_EXTRA_USER=price_...
```

---

## Usage Tracking Integration

### Models to Update

#### Customer Model
Add usage tracking:
```ruby
# app/models/customer.rb
after_create :increment_team_usage
after_destroy :decrement_team_usage

private

def increment_team_usage
  team.usage_limit&.increment_customers!
end

def decrement_team_usage
  team.usage_limit&.decrement_customers!
end
```

#### Job Model
```ruby
# app/models/job.rb
after_create :increment_team_usage
after_destroy :decrement_team_usage

private

def increment_team_usage
  team.usage_limit&.increment_jobs!
end

def decrement_team_usage
  team.usage_limit&.decrement_team_usage!
end
```

#### Work Model
```ruby
# app/models/work.rb
after_create :increment_team_usage
after_destroy :decrement_team_usage

private

def increment_team_usage
  team.usage_limit&.increment_works!
end

def decrement_team_usage
  team.usage_limit&.decrement_works!
end
```

#### Document Generation (wherever documents are created)
```ruby
# In document generation service
def generate_document
  usage = team.usage_limit

  # Check limits
  unless team.subscription.within_limits?(:documents_monthly) &&
         team.subscription.within_limits?(:documents_total)
    raise UsageLimitError, "Document generation limit reached"
  end

  # Generate document...

  # Track usage
  usage.increment_documents!
end
```

---

## Frontend Integration Examples

### 1. Check Current Subscription
```javascript
const response = await fetch('/api/v1/subscriptions', {
  headers: { 'Authorization': `Bearer ${token}` }
});
const { subscription, usage } = await response.json();
```

### 2. Upgrade to Pro
```javascript
// Get checkout session
const response = await fetch('/api/v1/subscriptions/checkout_session', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({ plan: 'pro', extra_users: 2 })
});

const { checkout_url } = await response.json();
// Redirect to Stripe checkout
window.location.href = checkout_url;
```

### 3. Send Referral
```javascript
const response = await fetch('/api/v1/referrals', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    emails: ['friend@example.com']
  })
});
```

### 4. Check Usage
```javascript
const response = await fetch('/api/v1/usage', {
  headers: { 'Authorization': `Bearer ${token}` }
});
const usage = await response.json();

// Show warning if near limit
if (usage.customers.percentage > 80) {
  showWarning('You are approaching your customer limit');
}
```

---

## API Response Examples

### GET /api/v1/subscriptions
```json
{
  "subscription": {
    "plan_type": "pro",
    "status": "active",
    "monthly_cost": 100.0,
    "extra_users_count": 2,
    "free_months_remaining": 3,
    "current_period_end": "2025-12-14T00:00:00Z"
  },
  "usage": {
    "customers": {
      "current": 45,
      "limit": null,
      "percentage": 0,
      "at_limit": false
    },
    "documents_monthly": {
      "current": 78,
      "limit": 100,
      "percentage": 78,
      "at_limit": false,
      "period_end": "2025-12-01T00:00:00Z"
    }
  }
}
```

### GET /api/v1/referrals/stats
```json
{
  "total_sent": 10,
  "accepted": 6,
  "converted": 3,
  "free_months_earned": 3,
  "pending_invitations": [
    {
      "email": "friend@example.com",
      "status": "accepted",
      "sent_at": "2025-11-01T00:00:00Z"
    }
  ]
}
```

---

## Cron Jobs Setup

Add to `config/initializers/sidekiq.rb`:

```ruby
schedule_file = "config/schedule.yml"

if File.exist?(schedule_file)
  Sidekiq::Cron::Job.load_from_hash!(YAML.load_file(schedule_file))
end
```

Create `config/schedule.yml`:

```yaml
usage_monthly_reset:
  cron: "0 0 1 * *" # 1st of every month at midnight
  class: "UsageMonthlyResetJob"
  queue: default
```

---

## Error Handling

### Usage Limit Errors
```ruby
class UsageLimitError < StandardError; end

# In controllers
rescue_from UsageLimitError do |e|
  render json: {
    error: e.message,
    upgrade_url: '/subscriptions/upgrade'
  }, status: :payment_required # 402
end
```

---

## Security Considerations

1. **Webhook Verification**: Always verify Stripe webhook signatures
2. **Team Isolation**: Ensure users can only manage their team's subscription
3. **Payment Data**: Never store card numbers - let Stripe handle it
4. **Free Month Abuse**: Track referral patterns to prevent abuse
5. **Usage Manipulation**: Validate usage increments/decrements

---

## Testing Strategy

### Unit Tests
- Model validations and methods
- Service object logic
- Usage limit calculations

### Integration Tests
- Complete subscription flows
- Stripe webhook handling (use Stripe mock events)
- Referral reward system

### Manual Testing Checklist
- [ ] Create Pro subscription via Stripe Checkout
- [ ] Verify webhook updates subscription in database
- [ ] Test usage limit enforcement
- [ ] Send referral, accept it, upgrade to Pro
- [ ] Verify free month awarded
- [ ] Test subscription cancellation
- [ ] Test adding/removing extra users

---

## Deployment Checklist

### Production Setup
- [ ] Switch to live Stripe keys
- [ ] Create live products and prices in Stripe
- [ ] Update webhook URL to production domain
- [ ] Set up monitoring for failed payments
- [ ] Configure email notifications for subscription events
- [ ] Set up Sidekiq cron jobs
- [ ] Test complete flow in production

---

## Future Enhancements

- [ ] Annual billing option (discount)
- [ ] Coupon/promo code support
- [ ] Team member invitations via subscription
- [ ] Usage analytics dashboard
- [ ] Referral leaderboard
- [ ] Custom referral codes
- [ ] Email notifications for usage warnings (80%, 90%, 100%)
- [ ] Granular permissions based on plan
- [ ] API rate limiting based on plan

---

## Support Resources

- **Stripe Documentation**: https://stripe.com/docs
- **Stripe Ruby Library**: https://github.com/stripe/stripe-ruby
- **Stripe Webhooks**: https://stripe.com/docs/webhooks
- **Stripe Testing**: https://stripe.com/docs/testing

---

## Notes

- Basic plan is completely free (no Stripe interaction unless extra users added)
- Pro plan requires Stripe subscription
- Free months are stored in database and consumed on each billing cycle
- Usage resets monthly for Pro plans (documents only)
- Referrals expire after 30 days (vs 7 days for team invitations)
