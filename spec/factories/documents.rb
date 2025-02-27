# frozen_string_literal: true

FactoryBot.define do
  factory :document do
    work
    profile_customer
    document_type { 'procuration' }
    format { :docx }
    status { :pending_review }

    transient do
      original_file { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'files', 'test_document.docx'), 'application/vnd.openxmlformats-officedocument.wordprocessingml.document') }
      signed_file { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'files', 'test_document.pdf'), 'application/pdf') }
    end

    after(:create) do |document, evaluator|
      document.original.attach(evaluator.original_file)
    end

    trait :with_original_and_signed do
      after(:create) do |document, evaluator|
        document.signed.attach(evaluator.signed_file)
        document.update(status: :signed, sign_source: :manual_signature)
      end
    end

    trait :approved do
      status { :approved }
      format { :pdf }

      after(:create) do |document, evaluator|
        document.original.attach(evaluator.original_file)
      end
    end

    # Trait para documentos aprovados com ambos os arquivos
    trait :approved_with_signed do
      status { :approved }
      format { :pdf }

      after(:create) do |document, evaluator|
        document.original.attach(evaluator.original_file)
        document.signed.attach(evaluator.signed_file)
      end
    end
  end
end
