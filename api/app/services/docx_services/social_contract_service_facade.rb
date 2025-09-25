# frozen_string_literal: true

require 'docx'

module DocxServices
  class SocialContractServiceFacade < BaseTemplate
    attr_reader :service

    def initialize(*args)
      super
      @service = determine_service
    end

    delegate :call, to: :service

    delegate :process_document, to: :service

    protected

    def template_path
      service.send(:template_path)
    end

    def file_name
      service.send(:file_name)
    end

    private

    def determine_service
      if single_lawyer?
        SocialContractServiceUnipessoal.new(document.id)
      else
        SocialContractServiceSociety.new(document.id)
      end
    end

    def single_lawyer?
      lawyers.length == 1
    end
  end
end
