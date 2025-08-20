# frozen_string_literal: true

# == Schema Information
#
# Table name: customer_works
#
#  id                  :bigint           not null, primary key
#  deleted_at          :datetime
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  profile_customer_id :bigint           not null
#  work_id             :bigint           not null
#
# Indexes
#
#  index_customer_works_on_deleted_at           (deleted_at)
#  index_customer_works_on_profile_customer_id  (profile_customer_id)
#  index_customer_works_on_work_id              (work_id)
#
# Foreign Keys
#
#  fk_rails_...  (profile_customer_id => profile_customers.id)
#  fk_rails_...  (work_id => works.id)
#
require 'rails_helper'

RSpec.describe CustomerWork, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
