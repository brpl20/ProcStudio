# frozen_string_literal: true

# == Schema Information
#
# Table name: documents
#
#  id                  :bigint           not null, primary key
#  deleted_at          :datetime
#  document_type       :string
#  format              :integer          default("docx"), not null
#  original_s3_key     :string
#  sign_source         :integer          default("no_signature"), not null
#  signed_s3_key       :string
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
require 'rails_helper'

RSpec.describe Document, type: :model do
  subject(:document) { build(:document) }

  describe 'Associations' do
    it { is_expected.to belong_to(:work) }
    it { is_expected.to belong_to(:profile_customer) }
  end

  describe 'CRUD' do
    it 'change model' do
      expect do
        create(:document)
      end.to change(described_class, :count).by_at_least(1)
    end

    it 'is attached a file' do
      document = create(:document)

      file = Rack::Test::UploadedFile.new('spec/factories/images/Ruby.jpg', 'image/jpg')

      S3UploadManager.upload_file(file, document, :original)

      expect(document.original).to be_attached
    end
  end
end
