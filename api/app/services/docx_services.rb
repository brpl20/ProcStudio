# frozen_string_literal: true

module DocxServices
  # Main entry point for DOCX document generation services
  #
  # Usage Examples:
  #
  # Generate a social contract:
  #   DocxServices::SocialContractService.new(document_id).call
  #
  # Use the Formatter directly:
  #   formatter = DocxServices::Formatter.new(
  #     { name: 'João', last_name: 'Silva', cpf: '12345678901' },
  #     entity_type: :person,
  #     gender: :male
  #   )
  #   formatter.full_name           # => "JOÃO SILVA"
  #   formatter.cpf                 # => "inscrito no CPF sob o nº 123.456.789-01"
  #   formatter.qualification       # => Full qualification text
  #
  # Use the EntityBuilder for model objects:
  #   builder = DocxServices::EntityBuilder.new
  #   formatter = builder.build(profile_customer)
  #   formatter.qualification       # => Full qualification based on model data
  #
  # Create custom document services by inheriting from BaseTemplate:
  #   class CustomDocumentService < DocxServices::BaseTemplate
  #     protected
  #
  #     def template_path
  #       'app/template_documents/custom.docx'
  #     end
  #
  #     def substitute_custom_fields(text)
  #       text.substitute('_custom_field_', custom_value)
  #     end
  #   end

  class << self
    def generate(office_id, document_type = nil)
      case document_type
      when 'social_contract', 'contrato_social', nil
        SocialContractServiceFacade.new(office_id).call
      else
        raise ArgumentError, "Unknown document type: #{document_type}"
      end
    end

    def format_entity(entity, options = {})
      EntityBuilder.new.build(entity, options)
    end

    def format_data(data, entity_type: :person, gender: :male)
      Formatter.new(data, entity_type: entity_type, gender: gender)
    end
  end
end
