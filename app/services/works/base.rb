# frozen_string_literal: true

module Works
  module Base
    private

    def service_name
      return :local if Rails.env.development?
      return :test  if Rails.env.test?

      :amazon
    end

    def substitute_client_info(text)
      translated_text = [
        customer.full_name.downcase.titleize,
        word_for_gender(customer.nationality, customer.gender),
        word_for_gender(customer.civil_status, customer.gender),
        ProfileCustomer.human_enum_name(:capacity, customer.capacity).downcase,
        customer.profession.downcase&.strip,
        "#{word_for_gender('owner', customer.gender)} do RG n° #{customer.rg} e #{word_for_gender('subscribe', customer.gender)} no CPF sob o n° #{customer.cpf}",
        customer.last_email&.strip, "residente e #{word_for_gender('live', customer.gender)}: #{address.street.to_s.downcase.titleize&.strip}, n° #{address.number}",
        address.description.to_s.downcase.titleize&.strip, "#{address.city&.strip} - #{address.state&.strip}, CEP #{address.zip_code&.strip} #{responsable}"
      ].join(', ')

      text.substitute('_proc_outorgante_', translated_text)
    end

    def responsable
      return nil unless customer.unable? && customer&.represent&.representor&.present?

      represent = customer.represent.representor
      represent_address = represent.addresses.first
      [
        ", #{word_for_gender('represent', represent.gender)} #{represent.full_name.downcase.titleize&.strip}",
        word_for_gender(represent.civil_status, represent.gender),
        "#{word_for_gender('owner', represent.gender)} do RG n° #{represent.rg} e #{word_for_gender('subscribe', represent.gender)} no CPF sob o n° #{represent.cpf}",
        represent.last_email&.strip,
        "residente e #{word_for_gender('live', represent.gender)}: #{represent_address.street.to_s.downcase.titleize&.strip}, n° #{represent_address.number}",
        represent_address.description.to_s.downcase.titleize&.strip,
        "#{represent_address.city&.strip} - #{represent_address.state&.strip}, CEP #{represent_address.zip_code&.strip}"
      ].join(', ')
    end

    def word_for_gender(text, gender)
      I18n.t("gender.#{text}.#{gender}")
    end

    # tranlate lawyers informations with office
    def lawyers_text
      text = []
      lawyers.each do |lawyer|
        text.push(lawyer.full_name&.strip)
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
        text.push(lawyer.full_name&.strip)
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
                            "#{I18n.t('general.lawyers')}: #{lawyers_text}", "integrante da #{office.name&.strip} inscrita sob o cnpj #{office.cnpj}",
                            "com endereço profissional à Rua #{office.street.to_s.downcase.titleize&.strip}", office.number.to_s, office.neighborhood.downcase.titleize&.strip,
                            "#{office.city&.strip}-#{office.state&.strip}", "e endereço eletrônico #{office.site&.strip}"
                          ].join(', ')
                        else
                          ["#{I18n.t('general.lawyers')}: #{lawyers_text_without_office}"].join(', ')
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
