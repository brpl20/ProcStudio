# frozen_string_literal: true

# == Schema Information
#
# Table name: compliance_notifications
#
#  id                :bigint           not null, primary key
#  description       :text             not null
#  ignored_at        :datetime
#  metadata          :json
#  notification_type :string           not null
#  resolved_at       :datetime
#  resource_type     :string
#  status            :string           default("pending"), not null
#  title             :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  resource_id       :bigint
#  team_id           :bigint           not null
#  user_id           :bigint
#
# Indexes
#
#  idx_on_resource_type_resource_id_a14cb9f6d9          (resource_type,resource_id)
#  index_compliance_notifications_on_notification_type  (notification_type)
#  index_compliance_notifications_on_status             (status)
#  index_compliance_notifications_on_team_id            (team_id)
#  index_compliance_notifications_on_user_id            (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (team_id => teams.id)
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe ComplianceNotification, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
