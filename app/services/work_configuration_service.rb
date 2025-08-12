# frozen_string_literal: true

class WorkConfigurationService
  attr_reader :work, :admin
  
  def initialize(work, admin = nil)
    @work = work
    @admin = admin
  end
  
  def self.create_initial_configuration(work, params = {})
    new(work, params[:admin]).create_initial_configuration(params)
  end
  
  def self.update_configuration(work, params = {})
    new(work, params[:admin]).update_configuration(params)
  end
  
  def create_initial_configuration(params = {})
    configuration = build_configuration_hash(params)
    
    work.work_configurations.create!(
      team: work.team,
      configuration: configuration,
      created_by: admin,
      updated_by: admin,
      status: 'active',
      effective_from: Time.current,
      notes: params[:notes]
    )
  end
  
  def update_configuration(params = {})
    current_config = work.current_configuration
    
    if current_config
      new_configuration = merge_configuration(current_config.configuration, params)
      current_config.create_new_version(new_configuration, admin)
    else
      create_initial_configuration(params)
    end
  end
  
  def add_office_to_work(office, lawyers = [])
    current_config = work.current_configuration || create_initial_configuration
    
    offices_data = current_config.configuration['offices'] || []
    
    # Check if office already exists
    return false if offices_data.any? { |o| o['office_id'] == office.id }
    
    office_data = build_office_data(office, lawyers)
    offices_data << office_data
    
    new_configuration = current_config.configuration.merge('offices' => offices_data)
    
    if current_config.persisted?
      current_config.create_new_version(new_configuration, admin)
    else
      current_config.update!(configuration: new_configuration)
    end
  end
  
  def remove_office_from_work(office_id)
    current_config = work.current_configuration
    return false unless current_config
    
    offices_data = current_config.configuration['offices'] || []
    offices_data.reject! { |o| o['office_id'] == office_id }
    
    new_configuration = current_config.configuration.merge('offices' => offices_data)
    current_config.create_new_version(new_configuration, admin)
  end
  
  def add_independent_lawyer(profile_admin, role = nil)
    current_config = work.current_configuration || create_initial_configuration
    
    lawyers_data = current_config.configuration['independent_lawyers'] || []
    
    # Check if lawyer already exists
    return false if lawyers_data.any? { |l| l['profile_admin_id'] == profile_admin.id }
    
    lawyer_data = build_lawyer_data(profile_admin, role)
    lawyers_data << lawyer_data
    
    new_configuration = current_config.configuration.merge('independent_lawyers' => lawyers_data)
    
    if current_config.persisted?
      current_config.create_new_version(new_configuration, admin)
    else
      current_config.update!(configuration: new_configuration)
    end
  end
  
  def remove_independent_lawyer(profile_admin_id)
    current_config = work.current_configuration
    return false unless current_config
    
    lawyers_data = current_config.configuration['independent_lawyers'] || []
    lawyers_data.reject! { |l| l['profile_admin_id'] == profile_admin_id }
    
    new_configuration = current_config.configuration.merge('independent_lawyers' => lawyers_data)
    current_config.create_new_version(new_configuration, admin)
  end
  
  def set_lead_lawyer(profile_admin)
    current_config = work.current_configuration || create_initial_configuration
    
    roles = current_config.configuration['roles'] || {}
    roles['lead_lawyer_id'] = profile_admin.id
    
    new_configuration = current_config.configuration.merge('roles' => roles)
    
    if current_config.persisted?
      current_config.create_new_version(new_configuration, admin)
    else
      current_config.update!(configuration: new_configuration)
    end
  end
  
  def set_fee_distribution(distribution_hash)
    current_config = work.current_configuration || create_initial_configuration
    
    # Validate that distribution sums to 100
    total = distribution_hash.values.sum(&:to_f)
    raise ArgumentError, "Fee distribution must sum to 100%, got #{total}%" unless total == 100.0
    
    new_configuration = current_config.configuration.merge('fee_distribution' => distribution_hash)
    
    if current_config.persisted?
      current_config.create_new_version(new_configuration, admin)
    else
      current_config.update!(configuration: new_configuration)
    end
  end
  
  def bulk_update_configuration(offices: [], independent_lawyers: [], roles: {}, fee_distribution: {})
    configuration = {
      'offices' => offices.map { |o| build_office_data(o[:office], o[:lawyers] || []) },
      'independent_lawyers' => independent_lawyers.map { |l| build_lawyer_data(l[:lawyer], l[:role]) },
      'roles' => roles,
      'fee_distribution' => fee_distribution
    }
    
    current_config = work.current_configuration
    
    if current_config
      current_config.create_new_version(configuration, admin)
    else
      work.work_configurations.create!(
        team: work.team,
        configuration: configuration,
        created_by: admin,
        updated_by: admin,
        status: 'active',
        effective_from: Time.current
      )
    end
  end
  
  private
  
  def build_configuration_hash(params)
    {
      'offices' => build_offices_array(params[:offices] || params[:office_ids]),
      'independent_lawyers' => build_lawyers_array(params[:lawyers] || params[:profile_admin_ids]),
      'roles' => params[:roles] || {},
      'fee_distribution' => params[:fee_distribution] || {}
    }
  end
  
  def build_offices_array(offices_param)
    return [] unless offices_param.present?
    
    if offices_param.is_a?(Array) && offices_param.first.is_a?(Hash)
      # Already structured data
      offices_param.map { |o| build_office_data(Office.find(o[:id]), o[:lawyers] || []) }
    elsif offices_param.is_a?(Array)
      # Just IDs
      Office.where(id: offices_param).map { |office| build_office_data(office) }
    else
      []
    end
  end
  
  def build_lawyers_array(lawyers_param)
    return [] unless lawyers_param.present?
    
    if lawyers_param.is_a?(Array) && lawyers_param.first.is_a?(Hash)
      # Already structured data
      lawyers_param.map { |l| build_lawyer_data(ProfileAdmin.find(l[:id]), l[:role]) }
    elsif lawyers_param.is_a?(Array)
      # Just IDs
      ProfileAdmin.where(id: lawyers_param).map { |lawyer| build_lawyer_data(lawyer) }
    else
      []
    end
  end
  
  def build_office_data(office, lawyers = [])
    {
      'office_id' => office.id,
      'office_name' => office.name,
      'cnpj' => office.cnpj,
      'oab' => office.oab_number,
      'lawyers' => lawyers.map { |lawyer| 
        lawyer_obj = lawyer.is_a?(ProfileAdmin) ? lawyer : ProfileAdmin.find(lawyer)
        build_lawyer_data(lawyer_obj)
      }
    }
  end
  
  def build_lawyer_data(profile_admin, role = nil)
    {
      'admin_id' => profile_admin.admin_id,
      'profile_admin_id' => profile_admin.id,
      'name' => profile_admin.name,
      'oab' => profile_admin.oab,
      'role' => role
    }
  end
  
  def merge_configuration(current_config, params)
    updated_config = current_config.deep_dup
    
    if params[:offices].present?
      updated_config['offices'] = build_offices_array(params[:offices])
    end
    
    if params[:lawyers].present?
      updated_config['independent_lawyers'] = build_lawyers_array(params[:lawyers])
    end
    
    if params[:roles].present?
      updated_config['roles'] = params[:roles]
    end
    
    if params[:fee_distribution].present?
      updated_config['fee_distribution'] = params[:fee_distribution]
    end
    
    updated_config
  end
end