# frozen_string_literal: true

require 'docx'

module DocxServices
  class SocialContractServiceFacade
    attr_reader :office, :service

    def initialize(office_id)
      @office = Office.find(office_id)
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
        SocialContractServiceUnipessoal.new(office.id)
      else
        SocialContractServiceSociety.new(office.id)
      end
    end

    def single_lawyer?
      lawyers_count == 1
    end
    
    def lawyers_count
      # Count UserProfiles with role=lawyer associated with this office
      office.user_profiles.where(role: 'lawyer').count
    end
  end
end
