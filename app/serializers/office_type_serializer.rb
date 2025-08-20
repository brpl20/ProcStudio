# frozen_string_literal: true

# == Schema Information
#
# Table name: office_types
#
#  id          :bigint           not null, primary key
#  description :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class OfficeTypeSerializer
  include JSONAPI::Serializer

  attributes :description
end
