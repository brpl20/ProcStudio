# frozen_string_literal: true

# == Schema Information
#
# Table name: office_phones
#
#  id         :bigint(8)        not null, primary key
#  office_id  :bigint(8)        not null
#  phone_id   :bigint(8)        not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class OfficePhone < ApplicationRecord
  belongs_to :office
  belongs_to :phone
end
