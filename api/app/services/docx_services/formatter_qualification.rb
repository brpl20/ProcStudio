# frozen_string_literal: true

require_relative 'formatter_constants'

module DocxServices
  class Formatter
    include FormatterConstants

    def initialize(data, entity_type: :person, gender: nil)
      @data = data.with_indifferent_access
      @entity_type = entity_type.to_sym
      @gender = (gender || val(:gender) || :male).to_sym
    end

    class << self
      def full_name(data, **)
        new(data, **).full_name
      end

      def cpf(data, **)
        new(data, **).cpf
      end

      # nb -> number_benefit -> numero de beneficio
      def number_benefit(data, **)
        new(data, **).number_benefit
      end

      # nit -> numero de inscrição do trabalhador
      def nit(data, **)
        new(data, **).nit
      end

      def oab(data, **)
        new(data, **).oab
      end

      def cnpj(data, **)
        new(data, **).cnpj
      end

      def nationality(data, **)
        new(data, **).nationality
      end

      def civil_status(data, **)
        new(data, **).civil_status
      end

      # Em algumas qualificações o e-mail pode ser útil então ele é opcional
      def email(data, **)
        new(data, **).email
      end

      # Em algumas qualificações o telefone pode ser útil então ele é opcional
      def phone(data, **)
        new(data, **).phone
      end

      # Profession não é tratado por que tem inserção livre pelo usuário

      def address(data, **)
        new(data, **).address
      end

      def qualification(data, **)
        new(data, **).qualification
      end

      def mask(data, **)
        new(data, **).mask
      end

      def full_name(upcase: true)
        name = clean_join(val(:name) val(:last_name))
        upcase ? name.upcase : name
      end

      def cpf
        return unless val(:cpf)

        prefix = DOCUMENT_PREFIXES[:cpf][@gender]
        "#{prefix} #{mask_cpf(val(:cpf))}"
      end

      def rg
        return unless val(:rg)

        prefix = DOCUMENT_PREFIXES[:rg][@gender]
        "#{prefix} #{val(:rg)}"
      end

      def number_benefit
        return unless val(:number_benefit)

        "#{DOCUMENT_PREFIXES[:number_benefit][:default]}: #{mask_nit(val(:number_benefit))}"
      end

      def nit(data, **)
        return unless data[:nit]

        prefix = DOCUMENT_PREFIXES[:nit][@gender]
        "#{prefix} #{mask_nit(data[:nit])}"
      end

      def oab
        return unless val(:oab)

        prefix = DOCUMENT_PREFIXES[:oab][@gender]
        "#{prefix} #{val(:oab)}"
      end

      def cnpj
        return unless val(:cnpj)

        prefix = DOCUMENT_PREFIXES[:cnpj][:company]
        "#{prefix} #{mask_cnpj(val(:cnpj))}"
      end

      def nationality
        return unless val(:nationality)

        prefix = DOCUMENT_PREFIXES[:nationality][@gender]
        "#{prefix} #{val(:nationality)}"
      end

      def civil_status
        return unless val(:civil_status)

        prefix = DOCUMENT_PREFIXES[:civil_status][@gender]
        "#{prefix} #{val(:civil_status)}"
      end

      def email
        return unless val(:email)
        prefix = DOCUMENT_PREFIXES[:email][:default]
        "#{prefix} #{val(:email)}"
      end

      def phone(mask: true)
        phone_value = val(:phone)
        return unless phone_value

        prefix = DOCUMENT_PREFIXES[:phone][:default]
        formatted_phone = mask ? mask_phone(phone_value) : phone_value
        "#{prefix} #{formatted_phone}"
      end

      # Profession


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
        zip_val = val(:zip_code)
        return unless zip_val

        "CEP #{mask_zip(zip_val)}"
      end

      def build_address(address, entity = nil)
        return unless address

        data = {
          street: address.street,
          number: address.number,
          complement: address.complement,
          neighborhood: address.neighborhood,
          city: address.city,
          state: address.state,
          zip_code: address.zip_code
        }

        entity_type = entity ? detect_entity_type(entity) : :person
        gender = entity&.gender if entity.respond_to?(:gender)

        new(
          data,
          entity_type: entity_type,
          gender: gender || :male
        )
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


      def qualification
        parts = []
        parts << full_name
        parts << nationality
        parts << civil_status
        parts << profession
        parts << cpf if @entity_type == :person
        parts << cnpj if @entity_type == :company
        parts << rg
        parts << oab if val(:oab)
        parts << nb if val(:number_benefit)
        parts << nit if val(:nit)
        parts << email if email
        parts << address

        parts.compact.reject(&:empty?).join(', ')
      end

    def capacity
      val(:capacity)&.downcase&.strip
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
