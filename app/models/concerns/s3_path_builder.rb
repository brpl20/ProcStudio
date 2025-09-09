# frozen_string_literal: true

module S3PathBuilder
  extend ActiveSupport::Concern

  included do
    # Get the S3 prefix for the current environment and team
    def s3_prefix
      "#{Rails.env}/team-#{team_id}"
    end

    # Build full S3 path from relative path
    def build_s3_path(relative_path)
      "#{s3_prefix}/#{relative_path}"
    end

    # Generate timestamp for file naming
    def generate_timestamp
      Time.current.strftime('%Y%m%d%H%M%S')
    end

    # Generate short hash for file uniqueness
    def generate_hash(content = nil)
      content ||= SecureRandom.hex(16)
      Digest::SHA256.hexdigest(content)[0..5]
    end

    # Build S3 key for office logo
    def build_logo_s3_key(extension)
      timestamp = generate_timestamp
      "#{s3_prefix}/offices/#{id}/logos/logo-#{timestamp}.#{extension}"
    end

    # Build S3 key for social contract
    def build_social_contract_s3_key(extension)
      timestamp = generate_timestamp
      hash = generate_hash
      "#{s3_prefix}/offices/#{id}/social-contracts/contract-#{timestamp}-#{hash}.#{extension}"
    end

    # Extract relative path from full S3 key
    def extract_relative_path(full_s3_key)
      return nil if full_s3_key.blank?

      # Remove environment and team prefix
      prefix_pattern = %r{^#{Regexp.escape(s3_prefix)}/}
      full_s3_key.gsub(prefix_pattern, '')
    end
  end

  class_methods do
    # Build S3 path for a given team
    def s3_prefix_for_team(team_id)
      "#{Rails.env}/team-#{team_id}"
    end
  end
end
