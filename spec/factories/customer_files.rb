# frozen_string_literal: true

FactoryBot.define do
  factory :customer_file do
    file_description { 'simple_procuration' }
    document_docx { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'factories', 'images', 'Ruby.jpg'), 'image/jpg') }
    profile_customer
  end
end
