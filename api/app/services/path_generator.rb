module PathGenerator
  extend self

  class UnsupportedModelError < StandardError; end
  class TeamNotFoundError < StandardError; end

  def for(model, options = {})
    case model
    when Office
      office_path(model, options)
    when UserProfile
      user_profile_path(model, options)
    when Job
      job_path(model, options)
    when Work
      work_path(model, options)
    when TempUpload
      temp_path(model, options)
    else
      raise UnsupportedModelError, "No path generator for #{model.class}"
    end
  end

  private

  def office_path(office, options = {})
    type = options[:file_type] || 'logo'

    # Determine extension based on file type or from the provided filename
    ext = options[:extension] || extract_extension_from_filename(options[:filename]) || default_extension_for_type(type)

    case type
    when 'logo'
      "#{base_prefix(office.team_id)}/offices/#{office.id}/logo/logo-#{timestamp}.#{ext}"
    when 'social_contract'
      "#{base_prefix(office.team_id)}/offices/#{office.id}/social-contracts/contract-#{timestamp}-#{random_hash}.#{ext}"
    else
      "#{base_prefix(office.team_id)}/offices/#{office.id}/#{type}/#{type}-#{timestamp}-#{random_hash}.#{ext}"
    end
  end

  def user_profile_path(profile, options = {})
    team_id = extract_team_id(profile)
    ext = options[:extension] || 'jpg'

    "#{base_prefix(team_id)}/user-profiles/#{profile.id}/avatar/avatar-#{timestamp}.#{ext}"
  end

  def job_path(job, options = {})
    team_id = extract_team_id(job)
    type = options[:file_type] || 'attachment'
    ext = options[:extension] || 'pdf'

    "#{base_prefix(team_id)}/jobs/#{job.id}/#{type}/#{type}-#{timestamp}-#{random_hash}.#{ext}"
  end

  def work_path(work, options = {})
    team_id = extract_team_id(work)
    type = options[:file_type] || 'document'
    ext = options[:extension] || 'pdf'

    "#{base_prefix(team_id)}/works/#{work.id}/#{type}/#{type}-#{timestamp}-#{random_hash}.#{ext}"
  end

  def temp_path(temp_upload, options = {})
    "#{base_prefix(temp_upload.team_id)}/temp-uploads/#{temp_upload.user_profile_id}/#{timestamp}-#{sanitize_filename(temp_upload.original_filename)}"
  end

  def base_prefix(team_id)
    "#{Rails.env}/team-#{team_id}"
  end

  def timestamp
    Time.current.strftime('%Y%m%d%H%M%S')
  end

  def random_hash
    SecureRandom.hex(6)
  end

  def extract_team_id(model)
    # Smart team extraction with validation
    team_id = case model
              when Office then model.team_id
              when UserProfile then model.user&.team_id || model.office&.team_id
              when Job then model.team_id
              when Work then model.team_id
              end

    raise TeamNotFoundError, "Cannot determine team for #{model.class}" if team_id.nil?
    team_id
  end

  def sanitize_filename(filename)
    # Remove special characters and spaces from filename
    filename.gsub(/[^0-9a-zA-Z.\-_]/, '_')
  end

  def extract_extension_from_filename(filename)
    return nil unless filename

    # Extract extension from filename (e.g., "file.docx" -> "docx")
    File.extname(filename).delete_prefix('.').downcase if filename.include?('.')
  end

  def default_extension_for_type(type)
    case type
    when 'logo'
      'jpg'
    when 'social_contract'
      'pdf'  # Default to PDF for social contracts, but will use actual extension when available
    when 'avatar'
      'jpg'
    else
      'pdf'
    end
  end
end