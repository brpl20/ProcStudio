# frozen_string_literal: true

# == Schema Information
#
# Table name: represents
#
#  id                  :bigint           not null, primary key
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  profile_customer_id :bigint           not null
#  representor_id      :bigint
#
# Indexes
#
#  index_represents_on_profile_customer_id  (profile_customer_id)
#  index_represents_on_representor_id       (representor_id)
#
# Foreign Keys
#
#  fk_rails_...  (profile_customer_id => profile_customers.id)
#  fk_rails_...  (representor_id => profile_customers.id)
#
class RepresentSerializer
  include JSONAPI::Serializer

  attributes :id, :profile_customer_id, :representor_id
end
