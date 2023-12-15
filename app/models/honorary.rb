# frozen_string_literal: true

# == Schema Information
#
# Table name: honoraries
#
#  id                     :bigint(8)        not null, primary key
#  fixed_honorary_value   :string
#  parcelling_value       :string
#  honorary_type          :string
#  percent_honorary_value :string
#  parcelling             :boolean
#  work_id                :bigint(8)        not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
class Honorary < ApplicationRecord
  belongs_to :work

  enum honorary_type: {
    work: 'trabalho',
    success: 'exito',
    both: 'ambos',
    bonus: 'pro_abono'
  }
end
