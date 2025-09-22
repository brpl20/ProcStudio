# frozen_string_literal: true

# Option 1: Batch operations to reduce savepoints
def process_pending_emails_optimized
  return if @pending_emails.blank?

  attrs_array = @pending_emails.is_a?(Array) ? @pending_emails : @pending_emails.values

  # Collect all email values first
  email_values = attrs_array.filter_map do |attrs|
    attrs = attrs.with_indifferent_access if attrs.respond_to?(:with_indifferent_access)
    next if attrs['_destroy'] == '1'

    attrs['email'] || attrs[:email]
  end.compact

  # Batch find/create emails
  existing_emails = Email.where(email: email_values).index_by(&:email)
  new_emails = email_values - existing_emails.keys

  # Create missing emails in one insert (fewer savepoints)
  if new_emails.any?
    Email.insert_all(new_emails.map { |e| { email: e, created_at: Time.current, updated_at: Time.current } })
    existing_emails.merge!(Email.where(email: new_emails).index_by(&:email))
  end

  # Batch create office_emails
  existing_office_emails = office_emails.joins(:email).where(emails: { email: email_values }).pluck('emails.email')
  emails_to_link = email_values - existing_office_emails

  if emails_to_link.any?
    office_email_attrs = emails_to_link.map do |email_value|
      {
        office_id: id,
        email_id: existing_emails[email_value].id,
        created_at: Time.current,
        updated_at: Time.current
      }
    end
    OfficeEmail.insert_all(office_email_attrs)
  end

  @pending_emails = nil
end

# Option 2: Use requires_new: false to avoid savepoints (less safe but valid)
def process_pending_emails_no_savepoints
  return if @pending_emails.blank?

  attrs_array = @pending_emails.is_a?(Array) ? @pending_emails : @pending_emails.values

  ActiveRecord::Base.transaction(requires_new: false) do
    attrs_array.each do |attrs|
      attrs = attrs.with_indifferent_access if attrs.respond_to?(:with_indifferent_access)
      next if attrs['_destroy'] == '1'

      email_value = attrs['email'] || attrs[:email]
      next if email_value.blank?

      email = Email.find_or_create_by(email: email_value)
      office_emails.find_or_create_by(email: email) unless office_emails.exists?(email: email)
    end
  end

  @pending_emails = nil
end
