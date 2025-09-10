# frozen_string_literal: true

class Customers
  class << self
    def configure_profile(profile, flags)
      profile.customer = create_customer(profile.emails.first.email)
      save_profile(profile)

      NewCustomerEmailMailer.notify_new_customer(profile.customer).deliver_later if flags[:flag_access_data]
    end

    private

    def create_customer(email)
      Customer.create(
        email: email,
        password: 'Cliente123#',
        password_confirmation: 'Cliente123#'
      )
    end

    def save_profile(profile)
      profile.save
    end
  end
end
