# frozen_string_literal: true

# == Schema Information
#
# Table name: recommendations
#
#  id                  :bigint           not null, primary key
#  commission          :decimal(, )
#  deleted_at          :datetime
#  percentage          :decimal(, )
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  profile_customer_id :bigint           not null
#  work_id             :bigint           not null
#
# Indexes
#
#  index_recommendations_on_deleted_at           (deleted_at)
#  index_recommendations_on_profile_customer_id  (profile_customer_id)
#  index_recommendations_on_work_id              (work_id)
#
# Foreign Keys
#
#  fk_rails_...  (profile_customer_id => profile_customers.id)
#  fk_rails_...  (work_id => works.id)
#
class RecommendationSerializer
  include JSONAPI::Serializer

  attributes :percentage, :commission, :profile_customer_id, :work_id
end
