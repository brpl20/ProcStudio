# frozen_string_literal: true

# == Schema Information
#
# Table name: honoraries
#
#  id                     :bigint           not null, primary key
#  deleted_at             :datetime
#  fixed_honorary_value   :string
#  honorary_type          :string
#  parcelling             :boolean
#  parcelling_value       :string
#  percent_honorary_value :string
#  work_prev              :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  work_id                :bigint           not null
#
# Indexes
#
#  index_honoraries_on_deleted_at  (deleted_at)
#  index_honoraries_on_work_id     (work_id)
#
# Foreign Keys
#
#  fk_rails_...  (work_id => works.id)
#

class Honorary < ApplicationRecord
  acts_as_paranoid

  belongs_to :work

  enum :honorary_type, {
    work: 'trabalho',
    success: 'exito',
    both: 'ambos',
    bonus: 'pro_abono'
  }
end
