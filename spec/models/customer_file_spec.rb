# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CustomerFile do
  subject(:customer_file) { build(:customer_file) }

  describe 'Associations' do
    it { is_expected.to belong_to(:profile_customer) }
  end

  describe 'CRUD' do
    it 'change model' do
      expect do
        create(:customer_file)
      end.to change(described_class, :count).by_at_least(1)
    end
    it 'is attached a file' do
      customer_file = create(:customer_file)
      customer_file.document_docx.attach(
        io: File.open('spec/factories/images/Ruby.jpg'),
        filename: 'Ruby.jpg',
        content_type: 'application/jpg'
      )
      expect(customer_file.document_docx).to be_attached
    end
  end
end
