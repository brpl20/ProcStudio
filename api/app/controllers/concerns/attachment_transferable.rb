# frozen_string_literal: true

# Concern for controllers that need attachment transfer functionality
module AttachmentTransferable
  extend ActiveSupport::Concern

  included do
    # Add transfer_attachment action to the controller
  end

  def transfer_attachment
    source_attachment = find_source_attachment
    target_model = find_target_model

    authorize_transfer!(source_attachment, target_model)

    service = AttachmentTransferService.new(
      file_metadata: source_attachment,
      target_model: target_model,
      user_profile: current_user.user_profile,
      options: transfer_options
    )

    result = service.call

    if result.success?
      render json: {
        success: true,
        message: result.message,
        data: {
          file_metadata_id: result.file_metadata.id,
          filename: result.file_metadata.filename,
          from: {
            type: params[:from_type] || source_attachment.attachable_type,
            id: params[:from_id] || source_attachment.attachable_id
          },
          to: {
            type: target_model.class.name,
            id: target_model.id
          },
          url: result.file_metadata.url
        }
      }, status: :ok
    else
      render json: {
        success: false,
        message: result.message,
        errors: result.errors
      }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound => e
    render json: {
      success: false,
      message: 'Resource not found',
      errors: [e.message]
    }, status: :not_found
  rescue ArgumentError => e
    render json: {
      success: false,
      message: e.message,
      errors: [e.message]
    }, status: :bad_request
  rescue StandardError => e
    Rails.logger.error "Transfer failed: #{e.message}"
    Rails.logger.error e.backtrace.first(10).join("\n")

    render json: {
      success: false,
      message: 'Internal server error during transfer',
      errors: [e.message]
    }, status: :internal_server_error
  end

  private

  def find_source_attachment
    if params[:attachment_id].present?
      # Find by attachment ID directly
      FileMetadata.find(params[:attachment_id])
    elsif params[:from_type].present? && params[:from_id].present?
      # Find by source model
      from_model = params[:from_type].constantize.find(params[:from_id])
      from_model.file_metadata.find(params[:file_metadata_id])
    else
      # Default to finding from current model
      resource = instance_variable_get("@#{controller_name.singularize}")
      resource.file_metadata.find(params[:file_metadata_id])
    end
  end

  def find_target_model
    target_type = params[:to_type] || params[:target_type]
    target_id = params[:to_id] || params[:target_id]

    raise ArgumentError, 'Target type and ID required' unless target_type && target_id

    # Validate the target type is a valid model
    unless valid_attachable_model?(target_type)
      raise ArgumentError, "Invalid target type: #{target_type}"
    end

    target_type.constantize.find(target_id)
  end

  def valid_attachable_model?(model_name)
    # List of models that support attachments
    %w[Office UserProfile ProfileCustomer Work Job].include?(model_name)
  end

  def authorize_transfer!(source_attachment, target_model)
    # Check authorization for source model (can read/manage)
    if source_attachment.attachable
      case source_attachment.attachable_type
      when 'Office'
        authorize source_attachment.attachable, :update?, policy_class: Admin::OfficePolicy
      when 'UserProfile'
        authorize source_attachment.attachable, :update?, policy_class: UserProfilePolicy
      when 'ProfileCustomer'
        authorize source_attachment.attachable, :update?, policy_class: Admin::CustomerPolicy
      when 'Work'
        authorize source_attachment.attachable, :update?, policy_class: Admin::WorkPolicy
      when 'Job'
        authorize source_attachment.attachable, :update?, policy_class: Admin::JobPolicy
      end
    end

    # Check authorization for target model (can write/manage)
    case target_model.class.name
    when 'Office'
      authorize target_model, :update?, policy_class: Admin::OfficePolicy
    when 'UserProfile'
      authorize target_model, :update?, policy_class: UserProfilePolicy
    when 'ProfileCustomer'
      authorize target_model, :update?, policy_class: Admin::CustomerPolicy
    when 'Work'
      authorize target_model, :update?, policy_class: Admin::WorkPolicy
    when 'Job'
      authorize target_model, :update?, policy_class: Admin::JobPolicy
    end
  end

  def transfer_options
    {
      reason: params[:reason],
      reorganize_s3: truthy_param?(:reorganize_s3),
      validate_compatibility: truthy_param?(:validate_compatibility)
    }.compact
  end

  def truthy_param?(param_name)
    ActiveModel::Type::Boolean.new.cast(params[param_name])
  end
end