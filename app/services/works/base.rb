# frozen_string_literal: true

module Works
  module Base
    private

    def service_name
      return :local if Rails.env.development?
      return :test  if Rails.env.test?

      :amazon
    end

    def responsable_company
      return nil unless @customer&.represent&.representor&.present?
      
      representor = @customer.represent.representor
      representor_address = representor.addresses.first
      
      [
        "neste ato representado por seu sócio administrador #{representor.full_name.upcase}",
        word_for_gender(representor.nationality, representor.gender),
        word_for_gender(representor.civil_status, representor.gender),
        "#{word_for_gender('owner', representor.gender)} do RG n° #{representor.rg} e #{word_for_gender('subscribe', representor.gender)} no CPF sob o n° #{representor.cpf}",
        representor.last_email,
        "residente e #{word_for_gender('live', representor.gender)} à #{representor_address.street.to_s.downcase.titleize}, n° #{representor_address.number}",
        representor_address.description.to_s.downcase.titleize,
        "#{representor_address.city} - #{representor_address.state}, CEP #{representor_address.zip_code}"
      ].reject(&:blank?).join(', ')
    end

    def mask_cnpj(cnpj)
      return "" if cnpj.blank?
      
      # Remove any non-digit characters
      digits = cnpj.to_s.gsub(/\D/, '')
      
      # Make sure we have exactly 14 digits
      return "" if digits.length != 14
      
      # Format as XX.XXX.XXX/XXXX-XX
      "#{digits[0..1]}.#{digits[2..4]}.#{digits[5..7]}/#{digits[8..11]}-#{digits[12..13]}"
    end

    def substitute_client_info(text)
      if customer.customer_type == "legal_person"
        # For companies (legal persons)
        responsable = responsable_company
        translated_text = [
          customer.name.upcase,
          "pessoa jurídica de direito privado",
          "inscrita no CNPJ sob o n° #{mask_cnpj(customer.cnpj)}",
          "com sede na #{address.street.to_s.downcase.titleize&.strip}, n° #{address.number}",
          address.description.to_s.downcase.titleize&.strip,
          "#{address.neighborhood&.strip}, #{address.city&.strip} - #{address.state&.strip}, CEP #{address.zip_code&.strip}",
          "#{responsable}"
        ].reject(&:blank?).join(', ')
        # responsable_company
        # binding.pry 
      else
        # Original code for individual persons
        translated_text = [
          customer.full_name.upcase,
          word_for_gender(customer.nationality, customer.gender),
          word_for_gender(customer.civil_status, customer.gender),
          capacity,
          customer.profession.downcase&.strip,
          "#{word_for_gender('owner', customer.gender)} do RG n° #{customer.rg} e #{word_for_gender('subscribe', customer.gender)} no CPF sob o n° #{customer.cpf}",
          customer.last_email&.strip, 
          "residente e #{word_for_gender('live', customer.gender)}: #{address.street.to_s.downcase.titleize&.strip}, n° #{address.number}",
          address.description.to_s.downcase.titleize&.strip, 
          "#{address.city&.strip} - #{address.state&.strip}, CEP #{address.zip_code&.strip}", 
          responsable
        ].reject(&:blank?).join(', ')
      end

    text.substitute('_proc_outorgante_', translated_text)
  end

    def capacity
      ProfileCustomer.human_enum_name(:capacity, @customer.capacity).downcase unless @customer.capacity == 'able'
    end

    def responsable
      return nil if @customer.able?
      return nil unless @customer&.represent&.representor&.present?

      representor = @customer.represent.representor
      representor_address = representor.addresses.first
      representor_text =
        if @customer.unable?
          "neste ato #{word_for_gender('represent', @customer.gender).downcase}"
        else
          "neste ato #{word_for_gender('assisted', @customer.gender).downcase}"
        end

      [
        "#{representor_text} #{representor.full_name.upcase}",
        word_for_gender(representor.civil_status, representor.gender),
        "#{word_for_gender('owner', representor.gender)} do RG n° #{representor.rg} e #{word_for_gender('subscribe', representor.gender)} no CPF sob o n° #{representor.cpf}",
        representor.last_email,
        "residente e #{word_for_gender('live', representor.gender)} à #{representor_address.street.to_s.downcase.titleize}, n° #{representor_address.number}",
        representor_address.description.to_s.downcase.titleize,
        "#{representor_address.city} - #{representor_address.state}, CEP #{representor_address.zip_code}"
      ].join(', ')
    end

    def word_for_gender(text, gender)
      I18n.t("gender.#{text}.#{gender}")
    end

    # tranlate lawyers informations with office
    def lawyers_text
      text = []
      lawyers.each do |lawyer|
        text.push(lawyer.full_name&.upcase)
        text.push(word_for_gender(lawyer.civil_status, lawyer.gender))
        text.push("OAB n° #{lawyer.oab&.strip}")
        text.push(word_for_gender(lawyer.nationality, lawyer.gender))
      end
      text.join(', ')
    end

    # tranlate lawyers informations without office
    def lawyers_text_without_office
      text = []
      lawyers.each do |lawyer|
        address = lawyer.addresses.first
        text.push(lawyer.full_name&.upcase)
        text.push(word_for_gender(lawyer.civil_status, lawyer.gender))
        text.push("OAB n° #{lawyer.oab&.strip}")
        text.push(word_for_gender(lawyer.nationality, lawyer.gender))
        text.push("com endereço: #{address.street.to_s.downcase.titleize&.strip}, n° #{address.number}")
        text.push(address.description.to_s.downcase.titleize&.strip)
        text.push("#{address.city&.strip} - #{address.state&.strip}, CEP #{address.zip_code&.strip}")
      end
      text.join(', ')
    end

    # outorgados paragraph
    def substitute_justice_agents(text)
      translated_text = if office.present?
                          [
                            lawyers_text, "integrante da #{office.name&.strip} inscrita sob o CNPJ #{office.cnpj}",
                            "com endereço profissional à Rua #{office.street.to_s.downcase.titleize&.strip}", office.number.to_s, office.neighborhood.downcase.titleize&.strip,
                            "#{office.city&.strip}-#{office.state&.strip}", "e endereço eletrônico #{office&.emails&.first&.email&.strip}"
                          ].join(', ')
                        else
                          lawyers_text_without_office
                        end

      text.substitute('_proc_outorgado_', translated_text)
    end

    def substitute_job(text)
      translated_text =
        work.procedures.map do |procedure|
          Work.human_enum_name(:procedure, procedure.downcase).downcase.titleize
        end

      translated_text[0] = "#{'Procedimento'.pluralize(translated_text.size)} #{translated_text.first}"
      translated_text[-1] = "#{translated_text[-1]}: "
      translated_text = translated_text.join(', ')
      translated_text << if work.social_security_areas.present?
                           "#{Work.human_enum_name(:subject, work.subject).downcase.titleize} - #{Work.human_enum_name(:social_security_areas, work.social_security_areas).downcase.titleize}"
                         else
                           Work.human_enum_name(:subject, work.subject).downcase.titleize
                         end

      text.substitute('_proc_job_', translated_text)
    end
  end
end
