# frozen_string_literal: true

# == Schema Information
#
# Table name: pending_documents
#
#  id                  :bigint           not null, primary key
#  deleted_at          :datetime
#  description         :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  profile_customer_id :bigint
#  work_id             :bigint           not null
#
# Indexes
#
#  index_pending_documents_on_deleted_at           (deleted_at)
#  index_pending_documents_on_profile_customer_id  (profile_customer_id)
#  index_pending_documents_on_work_id              (work_id)
#
# Foreign Keys
#
#  fk_rails_...  (profile_customer_id => profile_customers.id)
#  fk_rails_...  (work_id => works.id)
#
class PendingDocumentSerializer
  include JSONAPI::Serializer

  attributes :description, :work_id
end
