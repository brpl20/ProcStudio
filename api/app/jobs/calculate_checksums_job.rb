class CalculateChecksumsJob < ApplicationJob
  queue_as :low

  def perform(file_metadata_id)
    metadata = FileMetadata.find(file_metadata_id)
    return if metadata.checksum.present?

    Rails.logger.info "Calculating checksum for file: #{metadata.s3_key}"

    # Download and calculate checksum using streaming to avoid memory issues
    checksum = Digest::SHA256.new

    S3Manager.stream(metadata) do |chunk|
      checksum.update(chunk)
    end

    # Update the metadata with calculated checksum
    metadata.update!(checksum: checksum.hexdigest)

    Rails.logger.info "Checksum calculated for #{metadata.s3_key}: #{checksum.hexdigest}"
  rescue ActiveRecord::RecordNotFound
    Rails.logger.error "FileMetadata not found: #{file_metadata_id}"
  rescue => e
    Rails.logger.error "Failed to calculate checksum for #{file_metadata_id}: #{e.message}"
    raise
  end

  # Bulk process files without checksums
  def self.process_missing_checksums
    FileMetadata.where(checksum: nil).find_each do |metadata|
      CalculateChecksumsJob.perform_later(metadata.id)
    end
  end
end