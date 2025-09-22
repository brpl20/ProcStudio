# frozen_string_literal: true

module S3PathBuilder
  extend ActiveSupport::Concern

  included do
    # Generate timestamp for file naming
    def generate_timestamp
      Time.current.strftime('%Y%m%d%H%M%S')
    end

    # Generate short hash for file uniqueness
    def generate_hash(length = 6)
      SecureRandom.hex(length)
    end

    # Get the base S3 prefix for the current environment and team
    def s3_prefix
      "#{Rails.env}/team-#{team_id}"
    end

    # Build S3 key for office logo
    # Pattern: /env/team-{id}/offices/{office-id}/logo/logo-{timestamp}.{ext}
    def build_logo_s3_key(extension)
      timestamp = generate_timestamp
      "#{s3_prefix}/offices/#{id}/logo/logo-#{timestamp}.#{extension}"
    end

    # Build S3 key for social contract
    # Pattern: /env/team-{id}/offices/{office-id}/social-contracts/contract-{timestamp}-{hash}.{ext}
    def build_social_contract_s3_key(extension)
      timestamp = generate_timestamp
      hash = generate_hash(6)
      "#{s3_prefix}/offices/#{id}/social-contracts/contract-#{timestamp}-#{hash}.#{extension}"
    end

    # Build S3 key for user avatar
    # Pattern: /env/team-{id}/users/{user-id}/avatar/avatar-{timestamp}.{ext}
    def build_avatar_s3_key(extension)
      timestamp = generate_timestamp
      user_id = id if is_a?(User)
      "#{s3_prefix}/users/#{user_id}/avatar/avatar-#{timestamp}.#{extension}"
    end

    # Extract team_id based on the model
    def team_id
      case self
      when Office
        self[:team_id]
      when User
        # Assuming User has a team association or current_team method
        respond_to?(:current_team) ? current_team&.id : team&.id
      when UserProfile
        user&.team&.id || office&.team_id
      else
        raise NotImplementedError, "team_id not defined for #{self.class.name}"
      end
    end

    # Generate a presigned URL for an S3 key
    def generate_presigned_url(s3_key, expires_in: 3600)
      return nil if s3_key.blank?

      S3Service.presigned_url(s3_key, expires_in: expires_in)
    end

    # Generate a presigned download URL with content disposition
    def generate_presigned_download_url(s3_key, filename, expires_in: 3600)
      return nil if s3_key.blank?

      S3Service.presigned_download_url(s3_key, filename, expires_in: expires_in)
    end
  end

  class_methods do
    # Build S3 prefix for a given team
    def s3_prefix_for_team(team_id)
      "#{Rails.env}/team-#{team_id}"
    end

    # Build complete S3 path for any model
    def build_s3_path(team_id, path_components)
      "#{s3_prefix_for_team(team_id)}/#{path_components.join('/')}"
    end
  end
end
