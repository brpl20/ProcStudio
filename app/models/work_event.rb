# frozen_string_literal: true

# == Schema Information
#
# Table name: work_events
#
#  id          :bigint(8)        not null, primary key
#  description :string
#  date        :datetime
#  work_id     :bigint(8)        not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class WorkEvent < ApplicationRecord
  belongs_to :work

  validates :description, :date, presence: true
end
