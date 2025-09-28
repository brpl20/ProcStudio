# frozen_string_literal: true

module S3PathBuilder
  extend ActiveSupport::Concern

  included do
    include S3PathBuilder::InstanceMethods
  end

  module InstanceMethods
    def generate_timestamp
      Time.current.strftime('%Y%m%d%H%M%S')
    end

    def generate_hash(length = 6)
      SecureRandom.hex(length)
    end

    def s3_prefix
      "#{Rails.env}/team-#{team_id}"
    end

    def build_logo_s3_key(extension)
      timestamp = generate_timestamp
      "#{s3_prefix}/offices/#{id}/logo/logo-#{timestamp}.#{extension}"
    end

    def build_social_contract_s3_key(extension)
      timestamp = generate_timestamp
      hash = generate_hash(6)
      "#{s3_prefix}/offices/#{id}/social-contracts/contract-#{timestamp}-#{hash}.#{extension}"
    end

    def build_avatar_s3_key(extension)
      timestamp = generate_timestamp
      user_id = id if is_a?(User)
      "#{s3_prefix}/users/#{user_id}/avatar/avatar-#{timestamp}.#{extension}"
    end

    def team_id
      case self
      when Office then office_team_id
      when User then user_team_id
      when UserProfile then user_profile_team_id
      else
        raise NotImplementedError, "team_id not defined for #{self.class.name}"
      end
    end

    def generate_presigned_url(s3_key, expires_in: 3600)
      return nil if s3_key.blank?

      S3Service.presigned_url(s3_key, expires_in: expires_in)
    end

    def generate_presigned_download_url(s3_key, filename, expires_in: 3600)
      return nil if s3_key.blank?

      S3Service.presigned_download_url(s3_key, filename, expires_in: expires_in)
    end

    def build_work_document_s3_key(document_type, extension)
      WorkS3KeyBuilder.new(self, document_type, extension).build
    end

    def build_customer_document_s3_key(filename, extension)
      CustomerS3KeyBuilder.new(self, filename, extension).build
    end

    private

    def office_team_id
      self[:team_id]
    end

    def user_team_id
      respond_to?(:current_team) ? current_team&.id : team&.id
    end

    def user_profile_team_id
      user&.team&.id || office&.team_id
    end
  end

  class WorkS3KeyBuilder
    def initialize(model, document_type, extension)
      @model = model
      @document_type = document_type
      @extension = extension
    end

    def build
      timestamp = @model.generate_timestamp
      filename = document_type_to_filename(@document_type)
      work_team_id = extract_work_team_id
      work_id_value = extract_work_id

      "#{Rails.env}/team-#{work_team_id}/works/#{work_id_value}/" \
        "documents/#{@document_type}/#{filename}-#{timestamp}.#{@extension}"
    end

    private

    def extract_work_team_id
      return @model.work.team_id if @model.respond_to?(:work)
      return @model.team_id if @model.is_a?(Work)

      raise 'Cannot determine team_id for work document'
    end

    def extract_work_id
      return @model.work_id if @model.respond_to?(:work_id)
      return @model.work.id if @model.respond_to?(:work)

      @model.id
    end

    def document_type_to_filename(document_type)
      case document_type.to_s
      when 'procuration' then 'procuracao'
      when 'waiver' then 'renuncia'
      when 'deficiency_statement', 'deficiency statement' then 'declaracao_carencia'
      when 'honorary' then 'contrato_honorario'
      else
        document_type.to_s.parameterize
      end
    end
  end

  class CustomerS3KeyBuilder
    def initialize(model, filename, extension)
      @model = model
      @filename = filename
      @extension = extension
    end

    def build
      timestamp = @model.generate_timestamp
      customer_team_id = extract_customer_team_id
      customer_id = extract_customer_id

      "#{Rails.env}/team-#{customer_team_id}/profile-customers/" \
        "#{customer_id}/documents/#{@filename}-#{timestamp}.#{@extension}"
    end

    private

    def extract_customer_team_id
      return profile_customer_team_id if @model.respond_to?(:profile_customer)
      return direct_customer_team_id if @model.is_a?(ProfileCustomer)

      raise 'Cannot determine team_id for customer document'
    end

    def profile_customer_team_id
      @model.profile_customer.customer&.team_id ||
        @model.profile_customer.works.first&.team_id
    end

    def direct_customer_team_id
      @model.customer&.team_id || @model.works.first&.team_id
    end

    def extract_customer_id
      return @model.profile_customer_id if @model.respond_to?(:profile_customer_id)
      return @model.profile_customer.id if @model.respond_to?(:profile_customer)
      return @model.id if @model.is_a?(ProfileCustomer)

      raise "Cannot determine customer_id for #{@model.class.name}"
    end
  end

  class_methods do
    def s3_prefix_for_team(team_id)
      "#{Rails.env}/team-#{team_id}"
    end

    def build_s3_path(team_id, path_components)
      "#{s3_prefix_for_team(team_id)}/#{path_components.join('/')}"
    end
  end
end
