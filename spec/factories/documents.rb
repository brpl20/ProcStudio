# frozen_string_literal: true

FactoryBot.define do
  factory :document do
    document_type { 'procuration' }
    file { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'factories', 'images', 'Ruby.jpg'), 'image/jpg') }
    work
    profile_customer
  end
end
