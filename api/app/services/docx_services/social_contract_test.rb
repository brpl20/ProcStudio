#!/usr/bin/env rails runner
# frozen_string_literal: true

# Usage:
# rails runner app/services/docx_services/social_contract_test.rb             # Default: generates unipessoal
# rails runner app/services/docx_services/social_contract_test.rb unipessoal  # Generates unipessoal (single lawyer)
# rails runner app/services/docx_services/social_contract_test.rb society     # Generates society (multiple lawyers)

require 'fileutils'
require 'ostruct'
require 'docx'

# Parse command line arguments (remove the dash to avoid Rails option conflicts)
raw_mode = ARGV[0]
mode = case raw_mode
       when 'society', '-society'
         'society'
       when 'unipessoal', '-unipessoal', nil
         'unipessoal'
       else
         'unipessoal'
       end

Rails.logger.debug { "\n#{'=' * 70}" }
Rails.logger.debug 'SOCIAL CONTRACT DOCUMENT GENERATION TEST'
Rails.logger.debug '=' * 70
Rails.logger.debug { "\nMode: #{mode == 'society' ? 'Society (Multiple Partners)' : 'Unipessoal (Single Partner)'}" }
Rails.logger.debug '=' * 70

# Create output directory if it doesn't exist
output_dir = Rails.root.join('app/services/docx_services/output')
FileUtils.mkdir_p(output_dir)
Rails.logger.debug { "\nOutput directory: #{output_dir}" }

# Create a mock document and work for testing
class TestDocument
  attr_accessor :id, :work, :profile_customer, :document_type, :original_s3_key

  def initialize
    @id = 999
    @document_type = 'social_contract'
  end

  def build_work_document_s3_key(doc_type, extension)
    "test/documents/#{doc_type}_#{id}.#{extension}"
  end

  def update_column(column, value)
    send("#{column}=", value)
    true
  end
end

class TestWork
  attr_accessor :id, :user_profiles, :office, :procedures, :subject, :social_security_areas

  def initialize
    @id = 1001
    @procedures = ['administrative']
    @subject = 'consultation'
  end
end

class TestCustomer
  attr_accessor :id, :name, :full_name, :customer_type, :addresses

  def initialize
    @id = 2001
    @name = 'Escritório de Advocacia Teste'
    @full_name = 'Escritório de Advocacia Teste LTDA'
    @customer_type = 'legal_person'
    @addresses = []
  end
end

class TestAddress
  attr_accessor :street, :number, :city, :state, :zip_code, :neighborhood, :description

  def initialize
    @street = 'Rua dos Advogados'
    @number = '1000'
    @city = 'São Paulo'
    @state = 'SP'
    @zip_code = '01310-100'
    @neighborhood = 'Bela Vista'
    @description = 'Sala 501'
  end
end

class TestOffice
  attr_accessor :name, :street, :number, :city, :state, :zip, :cnpj, :emails, :neighborhood

  def initialize
    @name = 'Escritório de Advocacia Santos & Associados'
    @street = 'Avenida Paulista'
    @number = '1578'
    @city = 'São Paulo'
    @state = 'SP'
    @zip = '01310-200'
    @cnpj = '12345678000190'
    @neighborhood = 'Bela Vista'
    @emails = [OpenStruct.new(email: 'contato@santosadvocacia.com.br')]
  end
end

# Monkey-patch S3Service for testing
class S3Service
  class << self
    alias original_upload upload if method_defined?(:upload)

    def upload(file, key, _options = {})
      # For testing, copy the file to output directory instead of uploading to S3
      output_path = Rails.root.join('app/services/docx_services/output', File.basename(key))

      # Handle file object that might be a File or have a path method
      source_path = file.respond_to?(:path) ? file.path : file

      FileUtils.cp(source_path, output_path)
      Rails.logger.debug { "  ✅ File saved locally to: #{output_path}" }
      true
    end
  end
end

# Override BaseTemplate to use test data and skip real database
module DocxServices
  class SocialContractService < BaseTemplate
    # Override initialize to avoid database calls
    def initialize(document_id)
      # Don't call super - we'll inject test data manually
      @document_id = document_id
    end

    # Override to avoid database calls
    def save_document
      # Save to output directory instead of S3
      output_path = Rails.root.join('app/services/docx_services/output', file_name)
      FileUtils.cp(file_path, output_path)

      Rails.logger.debug "\n📄 Document generated successfully!"
      Rails.logger.debug { "  Output: #{output_path}" }
      Rails.logger.debug { "  Size: #{File.size(output_path)} bytes" }

      # Clean up temp file
      FileUtils.rm_f(file_path, true)

      true
    end
  end
end

# Setup test data
document = TestDocument.new
work = TestWork.new
customer = TestCustomer.new
address = TestAddress.new
customer.addresses << address
office = TestOffice.new

# Get real lawyers from database (UserProfile IDs 115 and 114)
begin
  if mode == 'society'
    # Multiple lawyers for society
    lawyer1 = UserProfile.find(115)
    lawyer2 = UserProfile.find(114)
    lawyers = [lawyer1, lawyer2]

    Rails.logger.debug "\n👥 Partners:"
    Rails.logger.debug { "  1. #{lawyer1.name} #{lawyer1.last_name}" }
    Rails.logger.debug { "     CPF: #{lawyer1.cpf}" }
    Rails.logger.debug { "     OAB: #{lawyer1.oab}" }
    Rails.logger.debug { "  2. #{lawyer2.name} #{lawyer2.last_name}" }
    Rails.logger.debug { "     CPF: #{lawyer2.cpf}" }
    Rails.logger.debug { "     OAB: #{lawyer2.oab}" }
  else
    # Single lawyer for unipessoal
    lawyer = UserProfile.find(115)
    lawyers = [lawyer]

    Rails.logger.debug "\n👤 Single Partner:"
    Rails.logger.debug { "  #{lawyer.name} #{lawyer.last_name}" }
    Rails.logger.debug { "  CPF: #{lawyer.cpf}" }
    Rails.logger.debug { "  OAB: #{lawyer.oab}" }
  end
rescue ActiveRecord::RecordNotFound
  Rails.logger.debug "\n⚠️  Warning: Could not find UserProfile records (115 or 114)"
  Rails.logger.debug '   Creating mock lawyers for testing...'

  # Create mock lawyers
  class MockLawyer
    attr_accessor :id, :name, :last_name, :cpf, :oab, :rg, :gender,
                  :civil_status, :nationality, :profession, :birth, :addresses

    def initialize(id, name, last_name)
      @id = id
      @name = name
      @last_name = last_name
      @cpf = id == 115 ? '12345678901' : '98765432109'
      @oab = id == 115 ? 'OAB/SP 123.456' : 'OAB/SP 654.321'
      @rg = id == 115 ? '12.345.678-9' : '98.765.432-1'
      @gender = id == 115 ? 'male' : 'female'
      @civil_status = id == 115 ? 'married' : 'single'
      @nationality = 'brazilian'
      @profession = 'advogado'
      @birth = Date.new(1980, 5, 15)
      @addresses = [TestAddress.new]
    end

    def full_name
      "#{@name} #{@last_name}".strip
    end

    # Alias for compatibility
    def lastname
      @last_name
    end
  end

  if mode == 'society'
    lawyer1 = MockLawyer.new(115, 'João', 'Silva Santos')
    lawyer2 = MockLawyer.new(114, 'Maria', 'Oliveira Costa')
    lawyers = [lawyer1, lawyer2]

    Rails.logger.debug "\n👥 Mock Partners:"
    Rails.logger.debug { "  1. #{lawyer1.full_name}" }
    Rails.logger.debug { "  2. #{lawyer2.full_name}" }
  else
    lawyer = MockLawyer.new(115, 'João', 'Silva Santos')
    lawyers = [lawyer]

    Rails.logger.debug "\n👤 Mock Single Partner:"
    Rails.logger.debug { "  #{lawyer.full_name}" }
  end
end

# Assign data to work
work.user_profiles = lawyers
work.office = office

# Assign to document
document.work = work
document.profile_customer = customer

Rails.logger.debug "\n📋 Office Information:"
Rails.logger.debug { "  Name: #{office.name}" }
Rails.logger.debug { "  CNPJ: #{office.cnpj}" }
Rails.logger.debug { "  Address: #{office.street}, #{office.number}" }
Rails.logger.debug { "  City: #{office.city}/#{office.state}" }
Rails.logger.debug { "  ZIP: #{office.zip}" }

Rails.logger.debug { "\n#{'-' * 70}" }
Rails.logger.debug 'GENERATING DOCUMENT...'
Rails.logger.debug '-' * 70

begin
  # Create service instance with test document
  service = DocxServices::SocialContractService.new(document.id)

  # Inject our test data
  service.instance_variable_set(:@document, document)
  service.instance_variable_set(:@work, work)
  service.instance_variable_set(:@customer, customer)
  service.instance_variable_set(:@address, address)
  service.instance_variable_set(:@lawyers, lawyers)
  service.instance_variable_set(:@office, office)

  # Generate the document
  result = service.call

  if result
    Rails.logger.debug "\n✅ SUCCESS!"
    Rails.logger.debug "\nDocument generated with the following details:"
    Rails.logger.debug { "  Template: #{lawyers.size == 1 ? 'CS-UNIPESSOAL-TEMPLATE.docx' : 'CS-TEMPLATE.docx'}" }
    Rails.logger.debug { "  Partners: #{lawyers.size}" }
    Rails.logger.debug '  Capital: R$ 10.000,00'
    Rails.logger.debug '  Quotes: 10.000'
    Rails.logger.debug { "  Distribution: #{(100.0 / lawyers.size).round(2)}% per partner" }
  else
    Rails.logger.debug "\n❌ FAILED to generate document"
  end
rescue StandardError => e
  Rails.logger.debug { "\n❌ ERROR: #{e.message}" }
  Rails.logger.debug e.backtrace.first(10).join("\n")
end

Rails.logger.debug { "\n#{'=' * 70}" }
Rails.logger.debug 'TEST COMPLETE'
Rails.logger.debug '=' * 70
Rails.logger.debug "\nCheck the output directory for generated files:"
Rails.logger.debug { "  #{output_dir}" }
Rails.logger.debug "\n"

# Restore original S3Service upload method if it was aliased
if S3Service.singleton_class.method_defined?(:original_upload)
  S3Service.singleton_class.class_eval do
    alias_method :upload, :original_upload
    remove_method :original_upload
  end
end
