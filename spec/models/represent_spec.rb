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
require 'rails_helper'

RSpec.describe Represent, type: :model do
  context 'Attributes' do
    it {
      is_expected.to have_attributes(
        id: nil,
        profile_customer_id: nil,
        created_at: nil,
        updated_at: nil,
        representor_id: nil
      )
    }
  end

  context 'Relations' do
    it { is_expected.to belong_to(:profile_customer) }
    it { is_expected.to belong_to(:representor).class_name('ProfileCustomer').optional }
  end
end
