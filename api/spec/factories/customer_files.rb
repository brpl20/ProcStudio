# frozen_string_literal: true

# == Schema Information
#
# Table name: customer_files
#
#  id                  :bigint           not null, primary key
#  deleted_at          :datetime
#  file_description    :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  profile_customer_id :bigint           not null
#
# Indexes
#
#  index_customer_files_on_deleted_at           (deleted_at)
#  index_customer_files_on_profile_customer_id  (profile_customer_id)
#
# Foreign Keys
#
#  fk_rails_...  (profile_customer_id => profile_customers.id)
#
FactoryBot.define do
  factory :customer_file do
    file_description { 'simple_procuration' }
    file { Rack::Test::UploadedFile.new(Rails.root.join('spec/factories/images/Ruby.jpg'), 'image/jpg') }
    profile_customer
  end
end
