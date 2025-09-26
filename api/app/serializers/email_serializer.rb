# frozen_string_literal: true

# == Schema Information
#
# Table name: emails
#
#  id             :bigint           not null, primary key
#  deleted_at     :datetime
#  email          :string
#  email_type     :string           default("main")
#  emailable_type :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  emailable_id   :bigint
#
# Indexes
#
#  index_emails_on_deleted_at  (deleted_at)
#  index_emails_on_emailable   (emailable_type,emailable_id)
#
class EmailSerializer
  include JSONAPI::Serializer

  attributes :id, :email
end
