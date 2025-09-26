# frozen_string_literal: true

require_relative 'formatter_constants'

module DocxServices
  class FormatterQualification
    include FormatterConstants

    attr_reader :data, :entity_type, :gender

    def initialize(entity, entity_type: nil, gender: nil)
      @data = extract_data(entity)
      @entity_type = determine_entity_type(entity, entity_type)
      @gender = determine_gender(entity, gender)
    end

    class << self
      def for(entity, **)
        new(entity, **)
      end
    end

    def full_name(upcase: false)
      name = clean_join(data[:name], data[:last_name])
      upcase ? name.upcase : name
    end

    def cpf
      return nil unless data[:cpf]

      prefix = DOCUMENT_PREFIXES[:cpf][gender]
      "#{prefix} #{mask_cpf(data[:cpf])}"
    end

    def cnpj
      return nil unless data[:cnpj]

      prefix = DOCUMENT_PREFIXES[:cnpj][:company]
      "#{prefix} #{mask_cnpj(data[:cnpj])}"
    end

    def rg
      return nil unless data[:rg]

      prefix = DOCUMENT_PREFIXES[:rg][gender]
      "#{prefix} #{data[:rg]}"
    end

    def oab
      return nil unless data[:oab]

      prefix = DOCUMENT_PREFIXES[:oab][gender]
      masked_oab = mask_oab(data[:oab])
      "#{prefix} #{masked_oab}"
    end

    def nit
      return nil unless data[:nit]

      "#{DOCUMENT_PREFIXES[:nit][:default]} #{mask_nit(data[:nit])}"
    end

    # number_benefit or nb -> número do benefício previdenciário
    def number_benefit
      return nil unless data[:number_benefit]

      "#{DOCUMENT_PREFIXES[:nb][:default]} #{mask_nb(data[:number_benefit])}"
    end

    def nationality
      return nil unless data[:nationality]

      nationality_key = data[:nationality].to_s.to_sym
      NATIONALITY.dig(gender, nationality_key) || data[:nationality].to_s.downcase
    end

    def civil_status
      return nil unless data[:civil_status]

      civil_status_key = data[:civil_status].to_s.to_sym
      CIVIL_STATUS.dig(gender, civil_status_key) || data[:civil_status].to_s.downcase
    end

    def profession
      return nil unless data[:profession]

      data[:profession].to_s.downcase
    end

    def email
      return nil unless data[:email]

      prefix = DOCUMENT_PREFIXES[:email][:default]
      "#{prefix} #{data[:email]}"
    end

    def phone(mask: true)
      return nil unless data[:phone]

      prefix = DOCUMENT_PREFIXES[:phone][:default]
      formatted = mask ? mask_phone(data[:phone]) : data[:phone]
      "#{prefix} #{formatted}"
    end

    def mother_name
      return nil unless data[:mother_name]

      prefix = DOCUMENT_PREFIXES[:mother_name][gender]
      "#{prefix} #{data[:mother_name].to_s.downcase.titleize.strip}"
    end

    def address(with_prefix: true)
      return nil unless has_address?

      prefix = if with_prefix
                 entity_type == :company ? ADDRESS_PREFIXES[:company][:default] : ADDRESS_PREFIXES[:person][gender]
               end

      parts = []
      parts << street if street
      parts << "nº #{number}" if number
      parts << complement if complement
      parts << neighborhood if neighborhood
      parts << "#{city} - #{state}" if city && state
      parts << zip_code if zip_code

      address_text = parts.compact.reject(&:empty?).join(', ')
      return nil if address_text.empty?

      with_prefix && prefix ? "#{prefix} #{address_text}" : address_text
    end

    def street
      return nil unless data[:street]

      data[:street].to_s.downcase.titleize.strip
    end

    def number
      data[:number]
    end

    def complement
      return nil unless data[:complement]

      data[:complement].to_s.downcase.titleize.strip
    end

    def neighborhood
      return nil unless data[:neighborhood]

      data[:neighborhood].to_s.downcase.titleize.strip.to_s
    end

    def city
      data[:city]&.strip
    end

    def state
      data[:state]&.strip
    end

    def zip_code
      return nil unless data[:zip_code]

      "CEP #{mask_zip(data[:zip_code])}"
    end

    def qualification(include_email: false, include_phone: false, include_mother_name: false, include_number_benefit: false, include_nit: false, include_oab: true, include_rg: true, include_cpf: true)
      parts = []

      parts << full_name.upcase

      if entity_type == :person
        parts << nationality
        parts << civil_status
        parts << profession
      end

      parts << cpf if entity_type == :person && include_cpf && cpf
      parts << cnpj if entity_type == :company && cnpj
      parts << rg if include_rg && rg
      parts << oab if include_oab && oab
      parts << number_benefit if include_number_benefit && number_benefit
      parts << nit if include_nit && nit

      parts << email if include_email && email
      parts << phone if include_phone && phone
      parts << mother_name if include_mother_name && mother_name

      parts << address

      parts.compact.reject(&:empty?).join(', ')
    end

    private

    def extract_data(entity)
      return entity if entity.is_a?(Hash)

      # Extract data from ActiveRecord model
      extracted = {}

      # Basic info
      extracted[:name] = entity.name if entity.respond_to?(:name)
      extracted[:last_name] = entity.last_name if entity.respond_to?(:last_name)
      extracted[:gender] = entity.gender if entity.respond_to?(:gender)

      # Documents
      extracted[:cpf] = entity.cpf if entity.respond_to?(:cpf)
      extracted[:cnpj] = entity.cnpj if entity.respond_to?(:cnpj)
      extracted[:rg] = entity.rg if entity.respond_to?(:rg)
      extracted[:oab] = entity.oab if entity.respond_to?(:oab)
      extracted[:nit] = entity.nit if entity.respond_to?(:nit)
      extracted[:number_benefit] = entity.number_benefit if entity.respond_to?(:number_benefit)

      # Personal info
      extracted[:nationality] = entity.nationality if entity.respond_to?(:nationality)
      extracted[:civil_status] = entity.civil_status if entity.respond_to?(:civil_status)
      extracted[:profession] = extract_profession(entity)
      extracted[:mother_name] = entity.mother_name if entity.respond_to?(:mother_name)

      # Contact
      extracted[:email] = extract_email(entity)
      extracted[:phone] = extract_phone(entity)

      # Address - check for address association first
      if entity.respond_to?(:address) && entity.address
        address = entity.address
        extracted[:street] = address.street if address.respond_to?(:street)
        extracted[:number] = address.number if address.respond_to?(:number)
        extracted[:complement] = address.complement if address.respond_to?(:complement)
        extracted[:neighborhood] = address.neighborhood if address.respond_to?(:neighborhood)
        extracted[:city] = address.city if address.respond_to?(:city)
        extracted[:state] = address.state if address.respond_to?(:state)
        extracted[:zip_code] = address.zip_code if address.respond_to?(:zip_code)
      elsif entity.respond_to?(:addresses) && entity.addresses.any?
        address = entity.addresses.first
        extracted[:street] = address.street if address.respond_to?(:street)
        extracted[:number] = address.number if address.respond_to?(:number)
        extracted[:complement] = address.complement if address.respond_to?(:complement)
        extracted[:neighborhood] = address.neighborhood if address.respond_to?(:neighborhood)
        extracted[:city] = address.city if address.respond_to?(:city)
        extracted[:state] = address.state if address.respond_to?(:state)
        extracted[:zip_code] = address.zip_code if address.respond_to?(:zip_code)
      else
        # Direct address fields on entity
        extracted[:street] = entity.street if entity.respond_to?(:street)
        extracted[:number] = entity.number if entity.respond_to?(:number)
        extracted[:complement] = entity.complement if entity.respond_to?(:complement)
        extracted[:neighborhood] = entity.neighborhood if entity.respond_to?(:neighborhood)
        extracted[:city] = entity.city if entity.respond_to?(:city)
        extracted[:state] = entity.state if entity.respond_to?(:state)
        extracted[:zip_code] = entity.zip_code if entity.respond_to?(:zip_code)
      end

      # Additional fields
      extracted[:capacity] = entity.capacity if entity.respond_to?(:capacity)

      extracted.with_indifferent_access
    end

    def determine_entity_type(entity, provided_type)
      return provided_type.to_sym if provided_type

      # Check if entity has CNPJ (company indicator)
      if entity.respond_to?(:cnpj) && entity.cnpj.present?
        :company
      elsif entity.is_a?(Hash) && entity[:cnpj].present?
        :company
      else
        :person
      end
    end

    def determine_gender(entity, provided_gender)
      return provided_gender.to_sym if provided_gender

      # Try to get gender from entity
      if entity.respond_to?(:gender) && entity.gender.present?
        entity.gender.to_sym
      elsif entity.is_a?(Hash) && entity[:gender].present?
        entity[:gender].to_sym
      else
        :male # Default
      end
    end

    def has_address?
      data[:street].present? || data[:city].present? || data[:state].present? || data[:zip_code].present?
    end

    def extract_email(entity)
      # Direct email attribute
      return entity.email if entity.respond_to?(:email) && entity.email.present?

      # For ProfileCustomer -> Customer
      if entity.respond_to?(:customer) && entity.customer.respond_to?(:email) && entity.customer.email.present?
        return entity.customer.email
      end

      # For UserProfile -> User
      if entity.respond_to?(:user) && entity.user.respond_to?(:email) && entity.user.email.present?
        return entity.user.email
      end

      # For Customer -> ProfileCustomer (reverse lookup)
      if entity.respond_to?(:profile_customer) && entity.profile_customer.respond_to?(:email) && entity.profile_customer.email.present?
        return entity.profile_customer.email
      end

      # For User -> UserProfile (reverse lookup)
      if entity.respond_to?(:user_profile) && entity.user_profile.respond_to?(:email) && entity.user_profile.email.present?
        return entity.user_profile.email
      end

      nil
    end

    def extract_phone(entity)
      # Direct phone attribute
      return entity.phone if entity.respond_to?(:phone) && entity.phone.present?

      # Check for phones polymorphic association - get first one
      if entity.respond_to?(:phones) && entity.phones.any?
        phone = entity.phones.first
        return phone.phone_number if phone.respond_to?(:phone_number) && phone.phone_number.present?
      end

      nil
    end

    def extract_profession(entity)
      # Direct profession attribute (for ProfileCustomer)
      return entity.profession if entity.respond_to?(:profession) && entity.profession.present?

      # For UserProfile with role field
      if entity.respond_to?(:role) && entity.role.present?
        role_key = entity.role.to_s.to_sym
        gender_key = determine_gender(entity, nil)
        return ROLE_TO_PROFESSION.dig(gender_key, role_key)
      end

      nil
    end

    def clean_join(*parts)
      parts
        .compact
        .map(&:to_s)
        .reject(&:empty?)
        .join(' ')
        .squish
    end

    # Masking methods
    def mask_cpf(cpf)
      return cpf unless cpf

      digits = cpf.to_s.gsub(/\D/, '')
      return cpf if digits.length != 11

      "#{digits[0..2]}.#{digits[3..5]}.#{digits[6..8]}-#{digits[9..10]}"
    end

    def mask_cnpj(cnpj)
      return cnpj unless cnpj

      digits = cnpj.to_s.gsub(/\D/, '')
      return cnpj if digits.length != 14

      "#{digits[0..1]}.#{digits[2..4]}.#{digits[5..7]}/#{digits[8..11]}-#{digits[12..13]}"
    end

    def mask_phone(phone)
      return phone unless phone

      digits = phone.to_s.gsub(/\D/, '')
      return phone if digits.length < 10

      if digits.length == 11
        "(#{digits[0..1]}) #{digits[2]}#{digits[3..5]}-#{digits[6..10]}"
      else
        "(#{digits[0..1]}) #{digits[2..5]}-#{digits[6..9]}"
      end
    end

    def mask_zip(zip)
      return zip unless zip

      digits = zip.to_s.gsub(/\D/, '')
      return zip if digits.length != 8

      "#{digits[0..4]}-#{digits[5..7]}"
    end

    def mask_nb(nb)
      return nb unless nb

      nb.to_s.gsub(/(\d{3})(\d{4})(\d{4})/, '\1.\2.\3-\4')
    end

    def mask_nit(nit)
      return nit unless nit

      nit.to_s.gsub(/(\d{3})(\d{5})(\d{2})(\d)/, '\1.\2.\3-\4')
    end

    def mask_oab(oab)
      return oab unless oab

      # Handle UserProfile format: "PR_54159" -> "OAB/PR 54.159"
      if oab.include?('_')
        state, number = oab.split('_')
        formatted_number = number.gsub(/(\d{2})(\d{3})/, '\1.\2')
        "OAB/#{state} #{formatted_number}"
      else
        # Handle other formats or return as-is
        oab
      end
    end
  end
end
