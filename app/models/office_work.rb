# frozen_string_literal: true

# == Schema Information
#
# Table name: office_works
#
#  id         :bigint(8)        not null, primary key
#  work_id    :bigint(8)        not null
#  office_id  :bigint(8)        not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class OfficeWork < ApplicationRecord
  belongs_to :office
  belongs_to :work
end
