# frozen_string_literal: true

# == Schema Information
#
# Table name: office_works
#
#  id         :bigint           not null, primary key
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  office_id  :bigint           not null
#  work_id    :bigint           not null
#
# Indexes
#
#  index_office_works_on_deleted_at  (deleted_at)
#  index_office_works_on_office_id   (office_id)
#  index_office_works_on_work_id     (work_id)
#
# Foreign Keys
#
#  fk_rails_...  (office_id => offices.id)
#  fk_rails_...  (work_id => works.id)
#

class OfficeWork < ApplicationRecord
  acts_as_paranoid

  belongs_to :office
  belongs_to :work
end
