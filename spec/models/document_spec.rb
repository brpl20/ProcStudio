# frozen_string_literal: true

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
      document.document_docx.attach(
        io: File.open('spec/factories/images/Ruby.jpg'),
        filename: 'Ruby.jpg',
        content_type: 'application/jpg'
      )
      expect(document.document_docx).to be_attached
    end
  end
end
