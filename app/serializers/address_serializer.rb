# frozen_string_literal: true

# == Schema Information
#
# Table name: addresses
#
#  id           :bigint           not null, primary key
#  city         :string
#  description  :string
#  neighborhood :string
#  number       :integer
#  state        :string
#  street       :string
#  zip_code     :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class AddressSerializer
  include JSONAPI::Serializer

  attributes :id, :description, :zip_code, :number, :neighborhood, :city, :state, :street
end
