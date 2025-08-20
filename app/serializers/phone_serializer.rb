# frozen_string_literal: true

# == Schema Information
#
# Table name: phones
#
#  id           :bigint           not null, primary key
#  phone_number :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class PhoneSerializer
  include JSONAPI::Serializer

  attributes :id, :phone_number
end
