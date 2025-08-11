# frozen_string_literal: true

module CustomerDetailDisplay
  extend ActiveSupport::Concern

  included do
    # Main method to display all customer details
    def show_details
      puts "=" * 80
      puts "CUSTOMER DETAILS".center(80)
      puts "=" * 80
      
      display_basic_info
      
      if individual_entity?
        display_individual_details
      elsif legal_entity?
        display_legal_entity_details
        display_law_office_details if profile.is_law_office?
      else
        puts "No profile associated with this customer"
      end
      
      puts "=" * 80
      return nil # Return nil to avoid cluttering console output
    end
    
    # Alias methods for convenience
    alias_method :details, :show_details
    alias_method :info, :show_details
    
    # Get all details as a hash (useful for APIs)
    def full_details
      details = {
        customer: basic_info_hash,
        profile_type: profile_type,
        profile: nil,
        contact_info: {
          addresses: [],
          phones: [],
          emails: [],
          bank_accounts: []
        }
      }
      
      if profile
        details[:profile] = profile_details_hash
        details[:contact_info] = contact_info_hash
        
        if legal_entity? && profile.is_law_office?
          details[:law_office] = law_office_details_hash
        end
      end
      
      details
    end
  end
  
  private
  
  # Display methods
  def display_basic_info
    puts "\n" + "CUSTOMER INFORMATION".center(80, '-')
    puts "ID: #{id}"
    puts "Email: #{email}"
    puts "Status: #{status}"
    puts "Team: #{team&.name || 'No team'}"
    puts "Created: #{created_at.strftime('%Y-%m-%d %H:%M')}"
    puts "Confirmed: #{confirmed_at ? confirmed_at.strftime('%Y-%m-%d %H:%M') : 'Not confirmed'}"
  end
  
  def display_individual_details
    return unless profile
    
    puts "\n" + "PERSONAL INFORMATION (Individual Entity)".center(80, '-')
    puts "Name: #{profile.full_name}"
    puts "CPF: #{format_cpf(profile.cpf)}"
    puts "RG: #{profile.rg || 'Not provided'}"
    puts "Birth Date: #{profile.birth ? profile.birth.strftime('%Y-%m-%d') : 'Not provided'}"
    puts "Age: #{profile.age || 'N/A'} years"
    puts "Gender: #{profile.gender || 'Not provided'}"
    puts "Nationality: #{profile.nationality || 'Not provided'}"
    puts "Civil Status: #{profile.civil_status || 'Not provided'}"
    puts "Profession: #{profile.profession || 'Not provided'}"
    puts "Mother's Name: #{profile.mother_name || 'Not provided'}"
    puts "NIT: #{profile.nit || 'Not provided'}"
    puts "INSS Password: #{profile.inss_password ? '***' : 'Not provided'}"
    puts "Invalid Person: #{profile.invalid_person? ? 'Yes' : 'No'}"
    
    display_contact_info(profile)
  end
  
  def display_legal_entity_details
    return unless profile
    
    puts "\n" + "COMPANY INFORMATION (Legal Entity)".center(80, '-')
    puts "Company Name: #{profile.name}"
    puts "CNPJ: #{format_cnpj(profile.cnpj)}"
    puts "State Registration: #{profile.state_registration || 'Not provided'}"
    puts "Entity Type: #{profile.entity_type&.humanize || 'Not specified'}"
    puts "Status: #{profile.status}"
    puts "Accounting Type: #{profile.accounting_type&.humanize || 'Not specified'}"
    puts "Number of Partners: #{profile.number_of_partners || 'Not specified'}"
    puts "Legal Representative: #{profile.representative_name || 'Not assigned'}"
    
    display_contact_info(profile)
  end
  
  def display_law_office_details
    office = profile.legal_entity_office
    return unless office
    
    puts "\n" + "LAW OFFICE INFORMATION".center(80, '-')
    puts "OAB ID: #{office.oab_id || 'Not provided'}"
    puts "Inscription Number: #{office.inscription_number || 'Not provided'}"
    puts "Legal Specialty: #{office.legal_specialty || 'Not specified'}"
    puts "Society Link: #{office.society_link || 'Not provided'}"
    
    if office.lawyers.any?
      puts "\nLAWYERS AND PARTNERS:"
      office.legal_entity_office_relationships.includes(:lawyer).each do |relationship|
        lawyer = relationship.lawyer
        puts "  • #{lawyer.full_name}"
        puts "    CPF: #{format_cpf(lawyer.cpf)}"
        puts "    Type: #{relationship.partnership_type&.humanize || 'Not specified'}"
        puts "    Ownership: #{relationship.ownership_percentage || 0}%"
      end
      puts "  Total Ownership: #{office.total_ownership_percentage}%"
    else
      puts "No lawyers associated with this office"
    end
  end
  
  def display_contact_info(entity)
    return unless entity.respond_to?(:addresses)
    
    # Addresses
    addresses = entity.addresses
    if addresses.any?
      puts "\nADDRESSES:"
      addresses.each_with_index do |address, index|
        puts "  #{index + 1}. #{address.is_primary ? '[PRIMARY] ' : ''}"
        puts "     #{address.street}, #{address.number}#{address.complement ? ' - ' + address.complement : ''}"
        puts "     #{address.neighborhood}, #{address.city} - #{address.state}" if address.neighborhood
        puts "     CEP: #{address.formatted_zip_code}"
        puts "     Country: #{address.country || 'Brasil'}"
      end
    else
      puts "\nADDRESSES: None registered"
    end
    
    # Phones
    phones = entity.phones
    if phones.any?
      puts "\nPHONES:"
      phones.each_with_index do |phone, index|
        whatsapp_indicator = phone.is_whatsapp ? ' 📱WhatsApp' : ''
        puts "  #{index + 1}. #{phone.is_primary ? '[PRIMARY] ' : ''}#{phone.formatted_number} (#{phone.phone_type || 'mobile'})#{whatsapp_indicator}"
      end
    else
      puts "\nPHONES: None registered"
    end
    
    # Emails
    emails = entity.emails
    if emails.any?
      puts "\nEMAILS:"
      emails.each_with_index do |email, index|
        verified_indicator = email.is_verified ? ' ✓' : ''
        puts "  #{index + 1}. #{email.is_primary ? '[PRIMARY] ' : ''}#{email.address} (#{email.display_name})#{verified_indicator}"
      end
    else
      puts "\nEMAILS: None registered"
    end
    
    # Bank Accounts
    bank_accounts = entity.bank_accounts
    if bank_accounts.any?
      puts "\nBANK ACCOUNTS:"
      bank_accounts.each_with_index do |account, index|
        puts "  #{index + 1}. #{account.is_primary ? '[PRIMARY] ' : ''}"
        puts "     #{account.display_name}"
        puts "     Type: #{account.account_type_name}"
        puts "     PIX: #{account.pix_key}" if account.pix_key.present?
      end
    else
      puts "\nBANK ACCOUNTS: None registered"
    end
  end
  
  # Hash methods for API responses
  def basic_info_hash
    {
      id: id,
      email: email,
      status: status,
      team_id: team_id,
      team_name: team&.name,
      created_at: created_at,
      confirmed_at: confirmed_at
    }
  end
  
  def profile_details_hash
    return nil unless profile
    
    if individual_entity?
      {
        type: 'IndividualEntity',
        id: profile.id,
        full_name: profile.full_name,
        cpf: profile.cpf,
        rg: profile.rg,
        birth_date: profile.birth,
        age: profile.age,
        gender: profile.gender,
        nationality: profile.nationality,
        civil_status: profile.civil_status,
        profession: profile.profession,
        mother_name: profile.mother_name,
        nit: profile.nit,
        invalid_person: profile.invalid_person
      }
    elsif legal_entity?
      {
        type: 'LegalEntity',
        id: profile.id,
        name: profile.name,
        cnpj: profile.cnpj,
        state_registration: profile.state_registration,
        entity_type: profile.entity_type,
        status: profile.status,
        accounting_type: profile.accounting_type,
        number_of_partners: profile.number_of_partners,
        legal_representative_id: profile.legal_representative_id,
        legal_representative_name: profile.representative_name
      }
    end
  end
  
  def contact_info_hash
    return {} unless profile&.respond_to?(:addresses)
    
    {
      addresses: profile.addresses.map do |a|
        {
          street: a.street,
          number: a.number,
          complement: a.complement,
          neighborhood: a.neighborhood,
          city: a.city,
          state: a.state,
          zip_code: a.zip_code,
          country: a.country,
          is_primary: a.is_primary,
          formatted_zip_code: a.formatted_zip_code
        }
      end,
      phones: profile.phones.map do |p|
        {
          number: p.number,
          formatted_number: p.formatted_number,
          phone_type: p.phone_type,
          is_primary: p.is_primary,
          is_whatsapp: p.is_whatsapp,
          whatsapp_link: p.whatsapp_link
        }
      end,
      emails: profile.emails.map do |e|
        {
          address: e.address,
          email_type: e.email_type,
          display_name: e.display_name,
          is_primary: e.is_primary,
          is_verified: e.is_verified
        }
      end,
      bank_accounts: profile.bank_accounts.map do |b|
        {
          bank_name: b.bank_name,
          bank_code: b.bank_code,
          agency: b.agency,
          account_number: b.account_number,
          account_type: b.account_type,
          account_type_name: b.account_type_name,
          pix_key: b.pix_key,
          display_name: b.display_name,
          is_primary: b.is_primary
        }
      end
    }
  end
  
  def law_office_details_hash
    office = profile.legal_entity_office
    return nil unless office
    
    {
      id: office.id,
      oab_id: office.oab_id,
      inscription_number: office.inscription_number,
      legal_specialty: office.legal_specialty,
      society_link: office.society_link,
      lawyers: office.legal_entity_office_relationships.map do |rel|
        {
          id: rel.lawyer_id,
          name: rel.lawyer.full_name,
          cpf: rel.lawyer.cpf,
          partnership_type: rel.partnership_type,
          ownership_percentage: rel.ownership_percentage
        }
      end,
      total_ownership: office.total_ownership_percentage
    }
  end
  
  # Formatting helpers
  def format_cpf(cpf)
    return cpf unless cpf&.match?(/^\d{11}$/)
    cpf.gsub(/(\d{3})(\d{3})(\d{3})(\d{2})/, '\1.\2.\3-\4')
  end
  
  def format_cnpj(cnpj)
    return cnpj unless cnpj&.match?(/^\d{14}$/)
    cnpj.gsub(/(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})/, '\1.\2.\3/\4-\5')
  end
  
  def format_cep(cep)
    return cep unless cep&.match?(/^\d{8}$/)
    cep.gsub(/(\d{5})(\d{3})/, '\1-\2')
  end
  
  def format_phone(phone)
    return phone unless phone&.match?(/^\d{10,11}$/)
    if phone.length == 11
      phone.gsub(/(\d{2})(\d{5})(\d{4})/, '(\1) \2-\3')
    else
      phone.gsub(/(\d{2})(\d{4})(\d{4})/, '(\1) \2-\3')
    end
  end
end