class CleanupExpiredFilesJob < ApplicationJob
  queue_as :maintenance

  def perform
    Rails.logger.info "Starting cleanup of expired files..."

    expired_count = 0
    error_count = 0

    # Find and delete all expired file metadata
    FileMetadata.expired.find_each do |metadata|
      begin
        # Delete from S3 and database
        S3Manager.delete(metadata)
        expired_count += 1
        Rails.logger.info "Deleted expired file: #{metadata.s3_key}"
      rescue => e
        error_count += 1
        Rails.logger.error "Failed to delete expired file #{metadata.s3_key}: #{e.message}"
      end
    end

    # Also cleanup expired temp uploads
    TempUpload.expired.find_each do |temp_upload|
      begin
        temp_upload.destroy
        Rails.logger.info "Deleted expired temp upload: #{temp_upload.id}"
      rescue => e
        Rails.logger.error "Failed to delete expired temp upload #{temp_upload.id}: #{e.message}"
      end
    end

    Rails.logger.info "Cleanup completed. Deleted #{expired_count} files, #{error_count} errors."
  end
end