# frozen_string_literal: true

class AgeTransitionCheckerJob < ApplicationJob
  queue_as :default

  def perform
    check_age_transitions
  end

  private

  def check_age_transitions
    # Find all customers whose capacity might need updating based on age
    ProfileCustomer.includes(:customer).find_each do |profile|
      next if profile.birth.blank?
      next if profile.deceased_at.present?

      current_age = calculate_age(profile.birth)
      expected_capacity = determine_capacity_by_age(current_age)

      # Skip if capacity is already correct or if manually overridden
      next if profile.capacity == expected_capacity

      # Check if this is an automatic age-based transition
      if should_transition?(profile, current_age, expected_capacity)
        handle_age_transition(profile, current_age, expected_capacity)
      end
    end
  end

  def calculate_age(birth_date)
    today = Date.current
    age = today.year - birth_date.year
    age -= 1 if today < birth_date + age.years
    age
  end

  def determine_capacity_by_age(age)
    case age
    when 0..15
      'unable'
    when 16..17
      'relatively'
    else
      'able'
    end
  end

  def should_transition?(profile, age, _expected_capacity)
    # Only transition if it's a birthday-triggered change
    today = Date.current
    birth_date = profile.birth

    # Check if today is the birthday that triggers a transition
    is_16th_birthday = age == 16 && birth_date.month == today.month && birth_date.day == today.day
    is_18th_birthday = age == 18 && birth_date.month == today.month && birth_date.day == today.day

    # Transition if it's a significant birthday
    return true if is_16th_birthday && profile.capacity == 'unable'
    return true if is_18th_birthday && profile.capacity == 'relatively'

    false
  end

  def handle_age_transition(profile, age, new_capacity)
    old_capacity = profile.capacity

    # Update capacity without triggering PaperTrail (automatic change)
    profile.paper_trail.without_versioning do
      profile.update!(capacity: new_capacity)
    end

    # Use NotificationService for compliance notification
    NotificationService.notify_capacity_change(
      profile_customer: profile,
      old_capacity: old_capacity,
      new_capacity: new_capacity,
      reason: 'age_transition'
    )

    Rails.logger.info "Age transition: ProfileCustomer ##{profile.id} changed from #{old_capacity} to #{new_capacity} (age: #{age})"
  end
end
