# frozen_string_literal: true

# == Schema Information
#
# Table name: documents
#
#  id                  :bigint           not null, primary key
#  deleted_at          :datetime
#  document_type       :string
#  format              :integer          default("docx"), not null
#  sign_source         :integer          default("no_signature"), not null
#  status              :integer          default("pending_review"), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  profile_customer_id :bigint
#  work_id             :bigint           not null
#
# Indexes
#
#  index_documents_on_deleted_at           (deleted_at)
#  index_documents_on_profile_customer_id  (profile_customer_id)
#  index_documents_on_work_id              (work_id)
#
# Foreign Keys
#
#  fk_rails_...  (profile_customer_id => profile_customers.id)
#  fk_rails_...  (work_id => works.id)
#
FactoryBot.define do
  factory :document do
    work
    profile_customer
    document_type { 'procuration' }
    format { :docx }
    status { :pending_review }

    transient do
      original_file { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/test_document.docx'), 'application/vnd.openxmlformats-officedocument.wordprocessingml.document') }
      signed_file { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/test_document.pdf'), 'application/pdf') }
    end

    after(:create) do |document, evaluator|
      S3UploadManager.upload_file(evaluator.original_file, document, :original)
    end

    trait :with_original_and_signed do
      after(:create) do |document, evaluator|
        S3UploadManager.upload_file(evaluator.signed_file, document, :signed)
        document.update(status: :signed, sign_source: :manual_signature)
      end
    end

    trait :approved do
      status { :approved }
      format { :pdf }

      # after(:create) do |document, evaluator|
      #   S3UploadManager.upload_file(evaluator.original_file, document, :original)
      # end
    end

    trait :signed do
      status { :signed }
      format { :pdf }
      sign_source { :zapsign }

      # after(:create) do |document, evaluator|
      #   S3UploadManager.upload_file(evaluator.original_file, document, :original)
      #   S3UploadManager.upload_file(evaluator.signed_file, document, :signed)
      # end
    end
  end
end
