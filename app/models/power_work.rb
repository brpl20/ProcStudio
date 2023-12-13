# frozen_string_literal: true

# == Schema Information
#
# Table name: power_works
#
#  id         :bigint(8)        not null, primary key
#  power_id   :bigint(8)        not null
#  work_id    :bigint(8)        not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class PowerWork < ApplicationRecord
  belongs_to :power
  belongs_to :work
end
