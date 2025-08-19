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

class Represent < ApplicationRecord
  belongs_to :profile_customer
  belongs_to :representor, class_name: 'ProfileCustomer', optional: true

  before_destroy :clear_representor

  def clear_representor
    update(representor_id: nil)
  end
end
