# frozen_string_literal: true

# == Schema Information
#
# Table name: user_society_compensations
#
#  id                :bigint           not null, primary key
#  amount            :decimal(10, 2)   not null
#  compensation_type :string           not null
#  effective_date    :date             not null
#  end_date          :date
#  notes             :text
#  payment_frequency :string           default("monthly"), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  user_office_id    :bigint           not null
#
# Indexes
#
#  index_user_society_compensations_on_user_office_id  (user_office_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_office_id => user_offices.id)
#

class UserSocietyCompensationSerializer
  include JSONAPI::Serializer

  attributes :compensation_type, :amount, :payment_frequency, :effective_date, :end_date, :notes

  attribute :amount_formatted do |object|
    MonetaryValidator.format(object.amount) if object.amount
  end

  attribute :created_at
  attribute :updated_at
end