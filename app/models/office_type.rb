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

class OfficeType < ApplicationRecord
  validates :description, uniqueness: { case_sensitive: true }, presence: true
end
