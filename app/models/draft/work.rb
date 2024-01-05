# frozen_string_literal: true

# == Schema Information
#
# Table name: draft_works
#
#  id         :bigint(8)        not null, primary key
#  name       :string
#  work_id    :bigint(8)        not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Draft::Work < ApplicationRecord
  belongs_to :work

  validates :name, uniqueness: { case_sensitive: false }, presence: true

  def work_id=(id)
    self.work = Work.find(id)
  end
end
