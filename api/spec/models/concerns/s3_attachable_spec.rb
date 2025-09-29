# frozen_string_literal: true

require 'rails_helper'

RSpec.describe S3Attachable do
  let(:office) { create(:office) }
  let(:user_profile) { create(:user_profile) }

  describe 'Office logo upload' do
    let(:file) do
      double('file',
             blank?: false,
             original_filename: 'logo.png',
             content_type: 'image/png',
             size: 1024)
    end

    before do
      allow(S3Service).to receive(:upload).and_return(true)
      allow(S3Service).to receive(:delete).and_return(true)
    end

    describe '#upload_logo' do
      it 'uploads logo successfully' do
        expect(office.upload_logo(file)).to be true
        expect(office.reload.logo_s3_key).to be_present
      end

      it 'returns false for blank file' do
        expect(office.upload_logo(nil)).to be false
      end

      it 'deletes old logo before uploading new one' do
        office.update_column(:logo_s3_key, 'old/logo.png') # rubocop:disable Rails/SkipsModelValidations
        expect(S3Service).to receive(:delete).with('old/logo.png')
        office.upload_logo(file)
      end
    end

    describe '#logo_url' do
      it 'returns presigned URL when logo exists' do
        office.update_column(:logo_s3_key, 'test/logo.png') # rubocop:disable Rails/SkipsModelValidations
        allow(S3Service).to receive(:presigned_url).and_return('https://s3.amazonaws.com/signed-url')

        expect(office.logo_url).to eq('https://s3.amazonaws.com/signed-url')
      end

      it 'returns nil when no logo exists' do
        expect(office.logo_url).to be_nil
      end
    end

    describe '#delete_logo!' do
      it 'deletes logo from S3 and clears key' do
        office.update_column(:logo_s3_key, 'test/logo.png') # rubocop:disable Rails/SkipsModelValidations
        expect(S3Service).to receive(:delete).with('test/logo.png').and_return(true)

        expect(office.delete_logo!).to be true
        expect(office.reload.logo_s3_key).to be_nil
      end
    end
  end

  describe 'UserProfile avatar upload' do
    let(:file) do
      double('file',
             blank?: false,
             original_filename: 'avatar.jpg',
             content_type: 'image/jpeg',
             size: 2048)
    end

    before do
      allow(S3Service).to receive(:upload).and_return(true)
      allow(S3Service).to receive(:delete).and_return(true)
    end

    describe '#upload_avatar' do
      it 'uploads avatar successfully' do
        expect(user_profile.upload_avatar(file)).to be true
        expect(user_profile.reload.avatar_s3_key).to be_present
      end

      it 'returns false for blank file' do
        expect(user_profile.upload_avatar(nil)).to be false
      end

      it 'deletes old avatar before uploading new one' do
        user_profile.update_column(:avatar_s3_key, 'old/avatar.jpg') # rubocop:disable Rails/SkipsModelValidations
        expect(S3Service).to receive(:delete).with('old/avatar.jpg')
        user_profile.upload_avatar(file)
      end
    end

    describe '#avatar_url' do
      it 'returns presigned URL when avatar exists' do
        user_profile.update_column(:avatar_s3_key, 'test/avatar.jpg') # rubocop:disable Rails/SkipsModelValidations
        allow(S3Service).to receive(:presigned_url).and_return('https://s3.amazonaws.com/signed-url')

        expect(user_profile.avatar_url).to eq('https://s3.amazonaws.com/signed-url')
      end

      it 'returns nil when no avatar exists' do
        expect(user_profile.avatar_url).to be_nil
      end
    end

    describe '#delete_avatar!' do
      it 'deletes avatar from S3 and clears key' do
        user_profile.update_column(:avatar_s3_key, 'test/avatar.jpg') # rubocop:disable Rails/SkipsModelValidations
        expect(S3Service).to receive(:delete).with('test/avatar.jpg').and_return(true)

        expect(user_profile.delete_avatar!).to be true
        expect(user_profile.reload.avatar_s3_key).to be_nil
      end
    end
  end

  describe 'Office social contracts' do
    let(:file) do
      double('file',
             blank?: false,
             original_filename: 'contract.pdf',
             content_type: 'application/pdf',
             size: 5000)
    end

    before do
      allow(S3Service).to receive(:upload).and_return(true)
      allow(S3Service).to receive(:delete).and_return(true)
    end

    describe '#upload_social_contract' do
      it 'uploads social contract successfully' do
        expect(office.upload_social_contract(file)).to be true
        expect(office.attachment_metadata.where(document_type: 'social_contract').count).to eq(1)
      end

      it 'returns false for blank file' do
        expect(office.upload_social_contract(nil)).to be false
      end

      it 'creates attachment metadata record' do
        office.upload_social_contract(file, uploaded_by_id: 1)

        metadata = office.attachment_metadata.last
        expect(metadata.document_type).to eq('social_contract')
        expect(metadata.filename).to eq('contract.pdf')
        expect(metadata.content_type).to eq('application/pdf')
        expect(metadata.byte_size).to eq(5000)
        expect(metadata.uploaded_by_id).to eq(1)
      end
    end

    describe '#social_contracts_with_urls' do
      let!(:contract_metadata) do
        office.attachment_metadata.create!(
          document_type: 'social_contract',
          s3_key: 'test/contract.pdf',
          filename: 'contract.pdf',
          content_type: 'application/pdf',
          byte_size: 5000
        )
      end

      before do
        allow(S3Service).to receive(:presigned_url).and_return('https://s3.amazonaws.com/view-url')
        allow(S3Service).to receive(:presigned_download_url).and_return('https://s3.amazonaws.com/download-url')
      end

      it 'returns contracts with presigned URLs' do
        contracts = office.social_contracts_with_urls

        expect(contracts.count).to eq(1)
        expect(contracts.first[:filename]).to eq('contract.pdf')
        expect(contracts.first[:url]).to eq('https://s3.amazonaws.com/view-url')
        expect(contracts.first[:download_url]).to eq('https://s3.amazonaws.com/download-url')
      end
    end

    describe '#delete_social_contract!' do
      let!(:contract_metadata) do
        office.attachment_metadata.create!(
          document_type: 'social_contract',
          s3_key: 'test/contract.pdf',
          filename: 'contract.pdf',
          content_type: 'application/pdf',
          byte_size: 5000
        )
      end

      it 'deletes social contract from S3 and removes metadata' do
        expect(S3Service).to receive(:delete).with('test/contract.pdf').and_return(true)

        expect(office.delete_social_contract!(contract_metadata.id)).to be true
        expect(office.attachment_metadata.find_by(id: contract_metadata.id)).to be_nil
      end

      it 'returns false for non-existent contract' do
        expect(office.delete_social_contract!(999_999)).to be false
      end
    end
  end
end
