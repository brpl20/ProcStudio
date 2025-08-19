# frozen_string_literal: true

# == Schema Information
#
# Table name: powers
#
#  id          :bigint           not null, primary key
#  category    :integer          not null
#  description :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class PowerSerializer
  include JSONAPI::Serializer

  attributes :id, :description, :category
end
