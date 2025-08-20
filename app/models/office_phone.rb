# frozen_string_literal: true

# == Schema Information
#
# Table name: office_phones
#
#  id         :bigint           not null, primary key
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  office_id  :bigint           not null
#  phone_id   :bigint           not null
#
# Indexes
#
#  index_office_phones_on_deleted_at  (deleted_at)
#  index_office_phones_on_office_id   (office_id)
#  index_office_phones_on_phone_id    (phone_id)
#
# Foreign Keys
#
#  fk_rails_...  (office_id => offices.id)
#  fk_rails_...  (phone_id => phones.id)
#

class OfficePhone < ApplicationRecord
  acts_as_paranoid

  belongs_to :office
  belongs_to :phone
end
