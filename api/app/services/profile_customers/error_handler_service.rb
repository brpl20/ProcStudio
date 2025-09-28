# frozen_string_literal: true

module ProfileCustomers
  class ErrorHandlerService
    def initialize(controller)
      @controller = controller
    end

    def handle_create_error(error, params)
      case error
      when ActiveRecord::RecordInvalid
        handle_validation_error(error)
      when ArgumentError
        handle_argument_error(error)
      when ActiveRecord::RecordNotUnique
        handle_uniqueness_error(error)
      when ActionController::ParameterMissing
        handle_missing_parameter_error(error)
      else
        handle_unexpected_error(error, params)
      end
    end

    def handle_update_error(error)
      case error
      when ActiveRecord::RecordInvalid
        handle_validation_error(error)
      when ActiveModel::UnknownAttributeError, ArgumentError
        handle_attribute_error(error)
      when ActionController::ParameterMissing
        handle_missing_parameter_error(error)
      else
        handle_update_unexpected_error(error)
      end
    end

    private

    attr_reader :controller

    def handle_validation_error(error)
      log_error('validation error', error.message)
      log_error('record errors', error.record.errors.full_messages) if error.record

      render_error(
        "Validation error: #{error.message}",
        error.record&.errors&.full_messages || [error.message],
        :unprocessable_content
      )
    end

    def handle_argument_error(error)
      log_error('invalid argument', error.message)
      render_error(error.message, [error.message], :unprocessable_content)
    end

    def handle_uniqueness_error(error)
      log_error('uniqueness constraint violation', error.message)
      render_error(
        'Este email já está em uso. Tente um email diferente.',
        ['Duplicate record: email already exists'],
        :unprocessable_content
      )
    end

    def handle_missing_parameter_error(error)
      log_error('missing parameters', error.message)
      render_error(
        "Required parameter missing: #{error.param}",
        ["Missing parameter: #{error.param}"],
        :bad_request
      )
    end

    def handle_attribute_error(error)
      log_error('attribute error', error.message)
      render_error(
        "Invalid attribute: #{error.message}",
        [error.message],
        :unprocessable_content
      )
    end

    def handle_unexpected_error(error, params)
      log_detailed_error(error, params)

      if Rails.env.development?
        render_development_error(error)
      else
        render_production_error
      end
    end

    def handle_update_unexpected_error(error)
      log_error('update unexpected error', "#{error.class} - #{error.message}")
      Rails.logger.error "Backtrace: #{error.backtrace.first(10).join("\n")}" if error.backtrace

      if Rails.env.development?
        render_update_development_error(error)
      else
        render_update_production_error
      end
    end

    def log_error(context, message)
      Rails.logger.error "ProfileCustomer #{context}: #{message}"
    end

    def log_detailed_error(error, params)
      Rails.logger.error "ProfileCustomer creation unexpected error: #{error.class} - #{error.message}"
      Rails.logger.error "Backtrace: #{error.backtrace.first(15).join("\n")}" if error.backtrace
      Rails.logger.error "Parameters: #{params.inspect}"
    end

    def render_error(message, errors, status)
      controller.render json: {
        success: false,
        message: message,
        errors: errors
      }, status: status
    end

    def render_development_error(error)
      render_error(
        "Development Error: #{error.class} - #{error.message}",
        [error.message],
        :internal_server_error
      ).tap do |response|
        response[:json][:backtrace] = error.backtrace.first(10)
      end
    end

    def render_production_error
      render_error(
        'Erro interno do servidor. Tente novamente ou contacte o suporte.',
        ['Internal server error'],
        :internal_server_error
      )
    end

    def render_update_development_error(error)
      render_error(
        "Development Error: #{error.class} - #{error.message}",
        [error.message],
        :unprocessable_content
      ).tap do |response|
        response[:json][:backtrace] = error.backtrace.first(5)
      end
    end

    def render_update_production_error
      render_error(
        'Erro ao atualizar perfil. Por favor, verifique os dados enviados.',
        ['Invalid data provided'],
        :unprocessable_content
      )
    end
  end
end
