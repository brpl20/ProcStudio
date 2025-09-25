The main concept of the change is that Work now will have Procedures, that can be: 'administrativo', 'judicial', 'extrajudicial' so we can remove the enum from Work model. 

The procedure model will make it possible to each work have one, two, three or even more procedures. 

Work will still be relevant but it can only live with a procedure attached: 

For procedure we will need to be administrativo, judicial, extrajudicial and create the following fields: 
- Number: usually all procedures have numbers, they can be a judicial number or even an administrative numer (for example Federal tax number) 
- where does the procedure take place) for example Cascavel - PR
    - City 
    - State 
    - so you don't need the full address of it 

- System: The digital system the Procedure runs 
    - INSS system
    - Eproc System 
    - Projudi System 
    - ECAC (Receita Federal) 
    - Inncra system 
    - Other ? 
- Competence : who is the entity responsible for the work Procedure ? 
    - Justiça Federal
    - Justiça do Trabalho
    - INSS 
    - Receita Federal
    - Justiça Estadual 
    - etc 
- Start Date, End-Date; 
    - When the procedure starts? It's started already or it will start in the future (maybe the lawyer needs a week or two to make the proper arrangements to start for example)
- class: an attribute of the procedure, maybe it's "Pequenas Causas", maybe is an "Rito Extraordinário (Justiça do Trabalho), Maybe is Commom and on and one  
    - 
- Responsible (not the responsable of our team, but in terms of Justice for example, how is the judge acting in that Procedure) example: Name of the Judge or the AUditor (this has to be created by the user because there is an infinite number of possibilities
- Law area (this has to connect to legal area model)
- Notes: general notes that our users will want to address in the procedure... 
- justice_free: true/false --- Justica gratuita status in this cenario the customer doesn't have to pay any taxes (for poor persons) 
- Valor da Causa: what is pleeded on the demand. Ex. 100k
- Valor da Condenação: what the judge actually values. Ex. 50k
- Valor recebido: what our customer actually received. Ex. 10k 
    - How can we make the best of these fields, they are kind of combined with honoraries and i think we must have a module to handle financial transactions on our system 
- Status : copy from work and remove from work : 
  enum :status, {
    in_progress: 'in_progress',
    paused: 'paused',
    completed: 'completed',
    archived: 'archived'
  }
- Conciliation: true/false -- autor manifesta interesse na conciliação? 
- Priority: { true/false type : age / sickness } : to determine if there is any priority in this case scenario
- plaintiff (one or +
- defendant (one or +) 
    - our system must be able to work with both caracteristics of the defendend and plaintiff... we going to attach our ProfileCustomer into one or another depending of the case cenario, in this case we will have all the informations needed. But the other part we will have only the name: Ex.: Our cliente is who is an plaintiff, and he is suing Maria, who is the defendant so we will have all the information of Joao attached to Customer / ProfileCustomer model, but we will not have all the informations of Maria, probably only the name, how can we manage that ? Users must be able to create this entity easily


Update current Honoraries Structure

  def change
    create_table :honoraries do |t| # maybe it's update the right thing here? 
      t.references :work, null: false, foreign_key: true
      # I want to have the possibility of the Honorary be glal for work, even if it has multiple Procedures, we must have a reference to this... if the honoraries are for each procedure, then they will be connected with an Honoraries instance for each one ... 
      t.references :procedure, foreign_key: true
      t.string :name
      t.text :description
      t.string :status, default: 'active' # active, completed, cancelled
      t.datetime :deleted_at
      
      t.timestamps
    end
    
    add_index :honoraries, :deleted_at
    add_index :honoraries, :status
  end
end

# Migration 2: Create honorary components with JSONB
class CreateHonoraryComponents < ActiveRecord::Migration[8.0]
  def change
    create_table :honorary_components do |t|
      t.references :honorary, null: false, foreign_key: true
      t.string :component_type, null: false
      t.jsonb :details, null: false, default: {}
      t.boolean :active, default: true
      t.integer :position # for ordering components
      
      t.timestamps
    end
    
    add_index :honorary_components, :component_type
    add_index :honorary_components, [:honorary_id, :component_type, :active]
    add_index :honorary_components, :details, using: :gin
  end
end

# Migration 3: Create legal taxes/costs structure
class CreateLegalCosts < ActiveRecord::Migration[8.0]
  def change
    create_table :legal_costs do |t|
      t.references :honorary, null: false, foreign_key: true
      t.boolean :client_responsible, default: true
      t.boolean :include_in_invoices, default: true
      t.decimal :admin_fee_percentage, precision: 5, scale: 2, default: 0
      
      t.timestamps
    end
    
    create_table :legal_cost_entries do |t|
      t.references :legal_cost, null: false, foreign_key: true
      t.string :cost_type, null: false # maps to BRAZILIAN_COST_TYPES
      t.string :name, null: false
      t.text :description
      t.decimal :amount, precision: 10, scale: 2
      t.boolean :estimated, default: false
      t.boolean :paid, default: false
      t.date :due_date
      t.date :payment_date
      t.string :receipt_number
      t.string :payment_method
      t.jsonb :metadata, default: {} # for additional fields
      
      t.timestamps
    end
    
    add_index :legal_cost_entries, :cost_type
    add_index :legal_cost_entries, [:legal_cost_id, :paid]
  end
end

# Models

# app/models/honorary.rb
class Honorary < ApplicationRecord
  acts_as_paranoid
  
  belongs_to :work
  belongs_to :procedure, optional: true
  
  has_many :components, -> { order(:position) }, 
           class_name: 'HonoraryComponent', 
           dependent: :destroy
  
  has_one :legal_cost, dependent: :destroy
  has_many :legal_cost_entries, through: :legal_cost
  
  validates :name, presence: true
  
  enum :status, {
    active: 'active',
    completed: 'completed',
    cancelled: 'cancelled'
  }
  
  # Component accessor methods
  HonoraryComponent::COMPONENT_TYPES.each do |type|
    define_method(type.underscore) do
      components.active.find_by(component_type: type)
    end
    
    define_method("has_#{type.underscore}?") do
      components.active.exists?(component_type: type)
    end
  end
  
  def add_component(type, details)
    components.create!(
      component_type: type,
      details: details,
      position: components.maximum(:position).to_i + 1
    )
  end
  
  def total_estimated_value
    components.active.sum { |c| c.calculate_total || 0 }
  end
end

# app/models/honorary_component.rb
class HonoraryComponent < ApplicationRecord
  belongs_to :honorary
  
  COMPONENT_TYPES = [
    'fixed_fee',
    'hourly_rate',
    'monthly_retainer',
    'success_fee',
    'performance_fee',
    'consultation_fee',
    'previdenciario_fee', # Social security specific
    'sucumbencia_fee'    # Brazilian loser-pays fee
  ].freeze
  
  validates :component_type, presence: true, inclusion: { in: COMPONENT_TYPES }
  validates :details, presence: true
  
  # Scopes
  scope :active, -> { where(active: true) }
  COMPONENT_TYPES.each do |type|
    scope type.to_sym, -> { where(component_type: type) }
  end
  
  # JSON Schema validations
  validate :validate_schema
  
  def validate_schema
    case component_type
    when 'fixed_fee'
      validate_fixed_fee_schema
    when 'hourly_rate'
      validate_hourly_rate_schema
    when 'monthly_retainer'
      validate_monthly_retainer_schema
    when 'success_fee'
      validate_success_fee_schema
    when 'performance_fee'
      validate_performance_fee_schema
    when 'consultation_fee'
      validate_consultation_fee_schema
    when 'previdenciario_fee'
      validate_previdenciario_fee_schema
    when 'sucumbencia_fee'
      validate_sucumbencia_fee_schema
    end
  end
  
  # Calculation methods
  def calculate_total
    case component_type
    when 'fixed_fee'
      details['amount']
    when 'hourly_rate'
      (details['rate'] || 0) * (details['estimated_hours'] || 0)
    when 'monthly_retainer'
      (details['monthly_amount'] || 0) * (details['months'] || 1)
    when 'previdenciario_fee'
      calculate_previdenciario_total
    else
      nil # Some fees can't be calculated upfront
    end
  end
  
  private
  
  def calculate_previdenciario_total
    base_income = details['monthly_income_average'] || 0
    months = details['benefit_months'] || 0
    percentage = details['percentage'] || 20
    
    (base_income * months * percentage / 100.0)
  end
  
  def validate_fixed_fee_schema
    required_fields = ['amount']
    validate_required_fields(required_fields)
    validate_numeric_field('amount')
    validate_numeric_field('installments', required: false)
  end
  
  def validate_hourly_rate_schema
    required_fields = ['rate']
    validate_required_fields(required_fields)
    validate_numeric_field('rate')
    validate_numeric_field('estimated_hours', required: false)
    validate_numeric_field('minimum_hours', required: false)
  end
  
  def validate_monthly_retainer_schema
    required_fields = ['monthly_amount']
    validate_required_fields(required_fields)
    validate_numeric_field('monthly_amount')
    validate_numeric_field('months', required: false)
  end
  
  def validate_success_fee_schema
    validate_numeric_field('percentage', required: false)
    validate_numeric_field('minimum_amount', required: false)
    validate_numeric_field('maximum_amount', required: false)
  end
  
  def validate_previdenciario_fee_schema
    required_fields = ['percentage']
    validate_required_fields(required_fields)
    validate_numeric_field('percentage')
    validate_numeric_field('monthly_income_average', required: false)
    validate_numeric_field('benefit_months', required: false)
  end
  
  def validate_sucumbencia_fee_schema
    validate_numeric_field('percentage', required: false)
    validate_numeric_field('base_amount', required: false)
  end
  
  def validate_consultation_fee_schema
    required_fields = ['amount']
    validate_required_fields(required_fields)
    validate_numeric_field('amount')
    validate_numeric_field('duration_minutes', required: false)
  end
  
  def validate_performance_fee_schema
    validate_array_field('milestones', required: false)
  end
  
  def validate_required_fields(fields)
    fields.each do |field|
      errors.add(:details, "#{field} is required") unless details[field].present?
    end
  end
  
  def validate_numeric_field(field, required: true)
    return unless required || details[field].present?
    
    value = details[field]
    if value.present? && !value.is_a?(Numeric)
      errors.add(:details, "#{field} must be a number")
    end
  end
  
  def validate_array_field(field, required: true)
    return unless required || details[field].present?
    
    value = details[field]
    if value.present? && !value.is_a?(Array)
      errors.add(:details, "#{field} must be an array")
    end
  end
end

# app/models/legal_cost.rb
class LegalCost < ApplicationRecord
  belongs_to :honorary
  has_many :entries, class_name: 'LegalCostEntry', dependent: :destroy
  
  def total_amount
    entries.sum(:amount)
  end
  
  def paid_amount
    entries.where(paid: true).sum(:amount)
  end
  
  def pending_amount
    entries.where(paid: false).sum(:amount)
  end
  
  def overdue_entries
    entries.where(paid: false).where('due_date < ?', Date.current)
  end
end

# app/models/legal_cost_entry.rb
class LegalCostEntry < ApplicationRecord
  belongs_to :legal_cost
  
  BRAZILIAN_COST_TYPES = {
    custas_judiciais: 'Custas Judiciais',
    taxa_judiciaria: 'Taxa Judiciária',
    diligencia_oficial: 'Diligência de Oficial de Justiça',
    guia_darf: 'Guia DARF',
    guia_gps: 'Guia GPS',
    guia_recolhimento_oab: 'Guia de Recolhimento OAB',
    despesas_cartorarias: 'Despesas Cartorárias',
    imposto_de_renda_advocacia: 'Imposto de Renda - Serviços Advocatícios',
    iss: 'ISS - Imposto sobre Serviços',
    distribuicao: 'Taxa de Distribuição',
    certidoes: 'Certidões',
    autenticacoes: 'Autenticações',
    reconhecimento_firma: 'Reconhecimento de Firma',
    edital: 'Publicação de Edital',
    pericia: 'Honorários Periciais',
    taxa_recursal: 'Taxa de Recurso'
  }.freeze
  
  validates :cost_type, presence: true, inclusion: { in: BRAZILIAN_COST_TYPES.keys.map(&:to_s) }
  validates :name, presence: true
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  
  scope :paid, -> { where(paid: true) }
  scope :pending, -> { where(paid: false) }
  scope :overdue, -> { pending.where('due_date < ?', Date.current) }
  
  def mark_as_paid!(payment_date: Date.current, receipt: nil, method: nil)
    update!(
      paid: true,
      payment_date: payment_date,
      receipt_number: receipt,
      payment_method: method
    )
  end
  
  def display_name
    BRAZILIAN_COST_TYPES[cost_type.to_sym] || name
  end
end

# db/seeds.rb - Honorary Component Templates
def seed_honorary_component_templates
  templates = [
    {
      type: 'fixed_fee',
      name: 'Honorários Fixos',
      default_details: {
        amount: 0,
        payment_terms: 'À vista',
        installments: 1,
        installment_value: 0,
        due_dates: []
      }
    },
    {
      type: 'hourly_rate',
      name: 'Honorários por Hora',
      default_details: {
        rate: 500.0,
        estimated_hours: 0,
        minimum_hours: 0,
        billing_increment: 15, # minutes
        includes_travel_time: false
      }
    },
    {
      type: 'monthly_retainer',
      name: 'Honorários Mensais',
      default_details: {
        monthly_amount: 0,
        months: 12,
        payment_day: 5,
        includes_services: [],
        hour_limit: nil
      }
    },
    {
      type: 'success_fee',
      name: 'Honorários de Êxito',
      default_details: {
        percentage: 30,
        base_calculation: 'valor_da_causa',
        minimum_amount: 0,
        maximum_amount: nil,
        triggers: []
      }
    },
    {
      type: 'consultation_fee',
      name: 'Consulta',
      default_details: {
        amount: 500.0,
        duration_minutes: 60,
        includes_written_opinion: false
      }
    },
    {
      type: 'previdenciario_fee',
      name: 'Honorários Previdenciários',
      default_details: {
        percentage: 20,
        monthly_income_average: 0,
        benefit_months: 0,
        retroactive_months: 0,
        includes_administrative_phase: true
      }
    },
    {
      type: 'sucumbencia_fee',
      name: 'Honorários de Sucumbência',
      default_details: {
        percentage: nil,
        base_amount: nil,
        paid_by: 'losing_party',
        court_determined: true
      }
    }
  ]
  
  # Store templates in Redis or a configuration table
  templates.each do |template|
    # You can create a HonoraryComponentTemplate model or store in cache
    Rails.cache.write("honorary_template_#{template[:type]}", template)
  end
end