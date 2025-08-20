# frozen_string_literal: true

# == Schema Information
#
# Table name: office_emails
#
#  id         :bigint           not null, primary key
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  email_id   :bigint           not null
#  office_id  :bigint           not null
#
# Indexes
#
#  index_office_emails_on_deleted_at  (deleted_at)
#  index_office_emails_on_email_id    (email_id)
#  index_office_emails_on_office_id   (office_id)
#
# Foreign Keys
#
#  fk_rails_...  (email_id => emails.id)
#  fk_rails_...  (office_id => offices.id)
#
class OfficeEmailSerializer
  include JSONAPI::Serializer

  attributes :office_id, :email_id
end
