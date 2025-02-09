# frozen_string_literal: true

FactoryBot.define do
  factory :document do
    work
    profile_customer
    document_type { 'procuration' }
    format { :docx }
    status { :waiting_signature }

    transient do
      file { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'files', 'test_document.docx'), 'application/vnd.openxmlformats-officedocument.wordprocessingml.document') }
    end

    after(:create) do |document, evaluator|
      document.file.attach(evaluator.file)
    end
  end
end
