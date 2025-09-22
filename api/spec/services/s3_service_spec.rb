# frozen_string_literal: true

require 'rails_helper'

RSpec.describe S3Service do
  describe '.upload' do
    let(:file) { double('file', blank?: false, original_filename: 'test.pdf', content_type: 'application/pdf') }
    let(:s3_key) { 'test/team-1/offices/1/logo/test.pdf' }
    let(:metadata) { { team_id: '1', office_id: '1' } }

    before do
      allow(S3Service).to receive(:extract_file_content).and_return('file content')
      allow(S3Service).to receive(:client).and_return(double(put_object: true))
    end

    it 'uploads file successfully' do
      expect(S3Service.upload(file, s3_key, metadata)).to be true
    end

    it 'returns false for blank file' do
      expect(S3Service.upload(nil, s3_key, metadata)).to be false
    end

    it 'returns false for blank s3_key' do
      expect(S3Service.upload(file, nil, metadata)).to be false
    end
  end

  describe '.presigned_url' do
    let(:s3_key) { 'test/team-1/offices/1/logo/logo.png' }
    let(:presigner) { double('presigner') }

    before do
      allow(S3Service).to receive(:presigner).and_return(presigner)
      allow(presigner).to receive(:presigned_url).and_return('https://s3.amazonaws.com/signed-url')
    end

    it 'generates presigned URL successfully' do
      url = S3Service.presigned_url(s3_key)
      expect(url).to eq('https://s3.amazonaws.com/signed-url')
    end

    it 'returns nil for blank s3_key' do
      expect(S3Service.presigned_url(nil)).to be_nil
    end
  end

  describe '.delete' do
    let(:s3_key) { 'test/team-1/offices/1/logo/old-logo.png' }
    let(:client) { double('client') }

    before do
      allow(S3Service).to receive(:client).and_return(client)
    end

    it 'deletes file successfully' do
      allow(client).to receive(:delete_object).and_return(true)
      expect(S3Service.delete(s3_key)).to be true
    end

    it 'returns false for blank s3_key' do
      expect(S3Service.delete(nil)).to be false
    end
  end

  describe '.exists?' do
    let(:s3_key) { 'test/team-1/offices/1/logo/logo.png' }
    let(:client) { double('client') }

    before do
      allow(S3Service).to receive(:client).and_return(client)
    end

    it 'returns true when file exists' do
      allow(client).to receive(:head_object)
      expect(S3Service.exists?(s3_key)).to be true
    end

    it 'returns false when file does not exist' do
      allow(client).to receive(:head_object).and_raise(Aws::S3::Errors::NotFound.new(nil, nil))
      expect(S3Service.exists?(s3_key)).to be false
    end

    it 'returns false for blank s3_key' do
      expect(S3Service.exists?(nil)).to be false
    end
  end
end