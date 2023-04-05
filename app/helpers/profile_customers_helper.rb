# frozen_string_literal: true

module ProfileCustomersHelper
  def options_for(enum_name)
    enum = ProfileCustomer.send(enum_name)
    enum.keys.map { |k| [k, ProfileCustomer.human_enum_name(enum_name, k.to_sym).humanize] }
  end
end
