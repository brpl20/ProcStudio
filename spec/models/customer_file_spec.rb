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

      file = Rack::Test::UploadedFile.new('spec/factories/images/Ruby.jpg', 'image/jpg')

      S3UploadManager.upload_file(file, customer_file, :file)

      expect(customer_file.file).to be_attached
    end
  end

  describe 'scope' do
    it 'simple_procuration' do
      create(:customer_file, file_description: 'simple_procuration')
      create(:customer_file, file_description: 'proof_of_address')
      expect(CustomerFile.simple_procuration.size).to eq(1)
    end
  end
end
