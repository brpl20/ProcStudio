# frozen_string_literal: true

# == Schema Information
#
# Table name: work_events
#
#  id          :bigint           not null, primary key
#  date        :datetime
#  deleted_at  :datetime
#  description :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  work_id     :bigint           not null
#
# Indexes
#
#  index_work_events_on_deleted_at  (deleted_at)
#  index_work_events_on_work_id     (work_id)
#
# Foreign Keys
#
#  fk_rails_...  (work_id => works.id)
#
class WorkEventSerializer
  include JSONAPI::Serializer

  attributes :date, :description, :work_id

  attribute :deleted do |object|
    object.deleted_at.present?
  end
end
