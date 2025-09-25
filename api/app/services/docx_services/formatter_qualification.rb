# frozen_string_literal: true

module DocxServices
  class Formatter
    DOCUMENT_PREFIXES = {
      cpf: {
        male: 'inscrito no CPF sob o nº',
        female: 'inscrita no CPF sob o nº'
      },
      cnpj: {
        company: 'inscrita no CNPJ sob o nº'
      },
      rg: {
        male: 'portador da cédula de identidade RG nº',
        female: 'portadora da cédula de identidade RG nº'
      },
      oab: {
        male: 'inscrito na OAB sob o nº',
        female: 'inscrita na OAB sob o nº'
      },
      nb: {
        default: 'número do benefício'
      },
      nit: {
        default: 'número de inscrição do trabalhador'
      }
    }.freeze

    ADDRESS_PREFIXES = {
      person: {
        male: 'residente e domiciliado',
        female: 'residente e domiciliada'
      },
      company: {
        default: 'com sede'
      }
    }.freeze

    def initialize(data, entity_type: :person, gender: nil)
      @data = data.with_indifferent_access
      @entity_type = entity_type.to_sym
      @gender = (gender || val(:gender) || :male).to_sym
    end

    class << self
      def full_name(data, **)
        new(data, **).full_name
      end

      def address(data, **)
        new(data, **).address
      end

      def cpf(data, **)
        new(data, **).cpf
      end

      def cnpj(data, **)
        new(data, **).cnpj
      end

      def qualification(data, **)
        new(data, **).qualification
      end

      def build(entity, options = {})
        entity_type = detect_entity_type(entity)
        gender = entity.gender if entity.respond_to?(:gender)

        data = extract_entity_data(entity)

        new(
          data,
          entity_type: entity_type,
          gender: gender || options[:gender] || :male
        )
      end

      def build_address(address, entity = nil)
        return unless address

        data = {
          street: address.street,
          number: address.number,
          # Handle both complement and description
          description: address.respond_to?(:complement) ? address.complement : address.description,
          neighborhood: address.neighborhood,
          city: address.city,
          state: address.state,
          zip_code: address.zip_code || address.zip
        }

        entity_type = entity ? detect_entity_type(entity) : :person
        gender = entity&.gender if entity.respond_to?(:gender)

        new(
          data,
          entity_type: entity_type,
          gender: gender || :male
        )
      end

      def build_from_hash(data, entity_type: :person, gender: :male)
        new(data, entity_type: entity_type, gender: gender)
      end

      private

      def detect_entity_type(entity)
        return :company if entity.respond_to?(:customer_type) && entity.customer_type == 'legal_person'
        return :company if entity.respond_to?(:cnpj) && entity.cnpj.present?
        return :office if entity.instance_of?(::Office)

        :person
      end

      def extract_entity_data(entity)
        data = {}

        # Basic identification
        data[:name] = entity.name if entity.respond_to?(:name)
        data[:full_name] = entity.full_name if entity.respond_to?(:full_name)
        data[:last_name] = entity.lastname if entity.respond_to?(:lastname)
        data[:lastname] = entity.last_name if entity.respond_to?(:last_name)

        # Documents
        data[:cpf] = entity.cpf if entity.respond_to?(:cpf)
        data[:cnpj] = entity.cnpj if entity.respond_to?(:cnpj)
        data[:rg] = entity.rg if entity.respond_to?(:rg)
        data[:oab] = entity.oab if entity.respond_to?(:oab)
        data[:number_benefit] = entity.number_benefit if entity.respond_to?(:number_benefit)
        data[:nit] = entity.nit if entity.respond_to?(:nit)

        # Personal info
        data[:gender] = entity.gender if entity.respond_to?(:gender)
        data[:civil_status] = entity.civil_status if entity.respond_to?(:civil_status)
        data[:marital_status] = entity.marital_status if entity.respond_to?(:marital_status)
        data[:nationality] = entity.nationality if entity.respond_to?(:nationality)
        data[:profession] = entity.profession if entity.respond_to?(:profession)
        data[:capacity] = entity.capacity if entity.respond_to?(:capacity)
        data[:birth] = entity.birth if entity.respond_to?(:birth)

        # Contact
        data[:email] = extract_email(entity)
        data[:last_email] = entity.last_email if entity.respond_to?(:last_email)
        data[:phone] = extract_phone(entity)

        # Address (if entity has embedded address fields)
        if entity.respond_to?(:street)
          data[:street] = entity.street
          data[:number] = entity.number if entity.respond_to?(:number)
          data[:neighborhood] = entity.neighborhood if entity.respond_to?(:neighborhood)
          data[:city] = entity.city if entity.respond_to?(:city)
          data[:state] = entity.state if entity.respond_to?(:state)
          data[:zip_code] = entity.zip_code || entity.zip if entity.respond_to?(:zip_code) || entity.respond_to?(:zip)
        end

        # Address from association
        if entity.respond_to?(:addresses) && entity.addresses.any?
          address = entity.addresses.first
          data[:street] ||= address.street
          data[:number] ||= address.number
          # Address model uses complement, not description
          data[:description] = address.complement if address.respond_to?(:complement)
          data[:description] ||= address.description if address.respond_to?(:description)
          data[:neighborhood] ||= address.neighborhood
          data[:city] ||= address.city
          data[:state] ||= address.state
          data[:zip_code] ||= address.zip_code
        end

        data
      end

      def extract_email(entity)
        return entity.email if entity.respond_to?(:email) && entity.email.present?
        return entity.last_email if entity.respond_to?(:last_email) && entity.last_email.present?

        return unless entity.respond_to?(:emails) && entity.emails.any?

        entity.emails.first.email
      end

      def extract_phone(entity)
        return entity.phone if entity.respond_to?(:phone) && entity.phone.present?
        return entity.telephone if entity.respond_to?(:telephone) && entity.telephone.present?
        return entity.phone_number if entity.respond_to?(:phone_number) && entity.phone_number.present?

        return unless entity.respond_to?(:phones) && entity.phones.any?

        phone_record = entity.phones.first
        # Phone model uses phone_number attribute
        phone_record&.phone_number
      end
    end

    def full_name(upcase: true)
      name = clean_join(val(:name) || val(:full_name), val(:last_name) || val(:lastname))
      upcase ? name.upcase : name.titleize
    end

    def cpf
      return unless val(:cpf)

      prefix = DOCUMENT_PREFIXES[:cpf][@gender]
      "#{prefix} #{mask_cpf(val(:cpf))}"
    end

    def cnpj
      return unless val(:cnpj)

      prefix = DOCUMENT_PREFIXES[:cnpj][:company]
      "#{prefix} #{mask_cnpj(val(:cnpj))}"
    end

    def rg
      return unless val(:rg)

      prefix = DOCUMENT_PREFIXES[:rg][@gender]
      "#{prefix} #{val(:rg)}"
    end

    def oab
      return unless val(:oab)

      prefix = DOCUMENT_PREFIXES[:oab][@gender]
      "#{prefix} #{val(:oab)}"
    end

    def nb
      return unless val(:number_benefit) || val(:nb)

      value = val(:number_benefit) || val(:nb)
      "#{DOCUMENT_PREFIXES[:nb][:default]}: #{mask_nb(value)}"
    end

    def nit
      return unless val(:nit)

      "#{DOCUMENT_PREFIXES[:nit][:default]}: #{mask_nit(val(:nit))}"
    end

    def email
      val(:email) || val(:last_email)
    end

    def phone(mask: true)
      phone_value = val(:phone) || val(:telephone)
      return unless phone_value

      mask ? mask_phone(phone_value) : phone_value
    end

    def street
      street_val = val(:street)
      return unless street_val

      street_val.to_s.downcase.titleize.strip
    end

    def number
      val(:number)
    end

    def neighborhood
      neighborhood_val = val(:neighborhood)
      return unless neighborhood_val

      "bairro #{neighborhood_val.to_s.downcase.titleize.strip}"
    end

    def city
      return unless val(:city)

      val(:city).strip
    end

    def state
      return unless val(:state)

      val(:state).strip
    end

    def zip_code
      zip_val = val(:zip_code) || val(:zip)
      return unless zip_val

      "CEP #{mask_zip(zip_val)}"
    end

    def address(with_prefix: true)
      prefix = if with_prefix
                 case @entity_type
                 when :company
                   ADDRESS_PREFIXES[:company][:default]
                 else
                   ADDRESS_PREFIXES[:person][@gender]
                 end
               end

      parts = []
      parts << street
      parts << "nº #{number}" if number
      parts << val(:description)&.to_s&.downcase&.titleize&.strip
      parts << neighborhood
      parts << "#{city} - #{state}" if city && state
      parts << zip_code

      address_text = parts.compact.reject(&:empty?).join(', ')
      return address_text unless with_prefix && prefix

      "#{prefix} #{address_text}"
    end

    def profession
      return unless val(:profession)

      val(:profession).downcase.strip
    end

    def marital_status
      status = val(:civil_status) || val(:marital_status)
      return unless status

      translate_gender("gender.#{status}", @gender)
    end

    def nationality
      return unless val(:nationality)

      translate_gender("gender.#{val(:nationality)}", @gender)
    end

    def qualification
      parts = []
      parts << full_name
      parts << nationality
      parts << marital_status
      parts << profession
      parts << cpf if @entity_type == :person
      parts << cnpj if @entity_type == :company
      parts << rg
      parts << oab if val(:oab)
      parts << nb if val(:number_benefit) || val(:nb)
      parts << nit if val(:nit)
      parts << email if email
      parts << address

      parts.compact.reject(&:empty?).join(', ')
    end

    def capacity
      val(:capacity)&.downcase&.strip
    end

    def birth
      return unless val(:birth)

      birth_date = val(:birth)
      return birth_date if birth_date.is_a?(String)

      birth_date.strftime('%d/%m/%Y') if birth_date.respond_to?(:strftime)
    end

    private

    def val(key)
      @data[key]
    end

    def clean_join(*parts)
      parts
        .compact
        .map(&:to_s)
        .reject(&:empty?)
        .join(' ')
        .squish
    end

    def translate_gender(key, gender)
      I18n.t("#{key}.#{gender}", default: I18n.t("#{key}.other", default: ''))
    end

    def mask_cpf(cpf)
      return unless cpf

      digits = cpf.to_s.gsub(/\D/, '')
      return cpf if digits.length != 11

      "#{digits[0..2]}.#{digits[3..5]}.#{digits[6..8]}-#{digits[9..10]}"
    end

    def mask_cnpj(cnpj)
      return unless cnpj

      digits = cnpj.to_s.gsub(/\D/, '')
      return cnpj if digits.length != 14

      "#{digits[0..1]}.#{digits[2..4]}.#{digits[5..7]}/#{digits[8..11]}-#{digits[12..13]}"
    end

    def mask_phone(phone)
      return unless phone

      digits = phone.to_s.gsub(/\D/, '')
      return phone if digits.length < 10

      if digits.length == 11
        "(#{digits[0..1]}) #{digits[2]}#{digits[3..5]}-#{digits[6..10]}"
      else
        "(#{digits[0..1]}) #{digits[2..5]}-#{digits[6..9]}"
      end
    end

    def mask_zip(zip)
      return unless zip

      digits = zip.to_s.gsub(/\D/, '')
      return zip if digits.length != 8

      "#{digits[0..4]}-#{digits[5..7]}"
    end

    def mask_nb(nb)
      return unless nb

      nb.to_s.gsub(/(\d{3})(\d{4})(\d{4})/, '\1.\2.\3-\4')
    end

    def mask_nit(nit)
      return unless nit

      nit.to_s.gsub(/(\d{3})(\d{5})(\d{2})(\d)/, '\1.\2.\3-\4')
    end
  end
end
