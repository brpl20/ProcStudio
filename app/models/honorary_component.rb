# frozen_string_literal: true

# == Schema Information
#
# Table name: honorary_components
#
#  id             :bigint           not null, primary key
#  active         :boolean          default(TRUE)
#  component_type :string           not null
#  details        :jsonb            not null
#  position       :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  honorary_id    :bigint           not null
#
# Indexes
#
#  index_honorary_components_lookup             (honorary_id,component_type,active)
#  index_honorary_components_on_component_type  (component_type)
#  index_honorary_components_on_details         (details) USING gin
#  index_honorary_components_on_honorary_id     (honorary_id)
#  index_honorary_components_on_position        (position)
#
# Foreign Keys
#
#  fk_rails_...  (honorary_id => honoraries.id)
#
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
    'sucumbencia_fee' # Brazilian loser-pays fee
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

  def display_name
    I18n.t("honorary_components.types.#{component_type}", default: component_type.humanize)
  end

  def formatted_details
    case component_type
    when 'fixed_fee'
      format_fixed_fee
    when 'hourly_rate'
      format_hourly_rate
    when 'monthly_retainer'
      format_monthly_retainer
    when 'success_fee'
      format_success_fee
    when 'previdenciario_fee'
      format_previdenciario_fee
    else
      details
    end
  end

  private

  def calculate_previdenciario_total
    base_income = details['monthly_income_average'] || 0
    months = details['benefit_months'] || 0
    percentage = details['percentage'] || 20

    (base_income * months * percentage / 100.0)
  end

  def format_fixed_fee
    {
      amount: format_currency(details['amount']),
      installments: details['installments'],
      payment_terms: details['payment_terms']
    }
  end

  def format_hourly_rate
    {
      rate: format_currency(details['rate']),
      estimated_hours: details['estimated_hours'],
      total: format_currency(calculate_total)
    }
  end

  def format_monthly_retainer
    {
      monthly_amount: format_currency(details['monthly_amount']),
      months: details['months'],
      total: format_currency(calculate_total)
      # TD: Due Date
    }
  end

  def format_success_fee
    {
      percentage: "#{details['percentage']}%",
      minimum: format_currency(details['minimum_amount']),
      maximum: format_currency(details['maximum_amount'])
      # TD: Max - Mim ? Relevante?
      # TD: Como combinar com o valor da causa?
    }
  end

  def format_previdenciario_fee
    {
      percentage: "#{details['percentage']}%",
      monthly_income: format_currency(details['monthly_income_average']),
      months: details['benefit_months'],
      estimated_total: format_currency(calculate_total)
      # TD: Valor fixo em parcelas de benefício
      # TD: Valor variável em
      # TD: Parcelamento?
    }
  end

  def format_currency(value)
    return nil unless value

    ActionController::Base.helpers.number_to_currency(value, unit: 'R$', separator: ',', delimiter: '.')
  end

  def validate_fixed_fee_schema
    required_fields = ['amount']
    validate_required_fields(required_fields)
    validate_numeric_field('amount')
    validate_numeric_field('installments', required: false)
    # TD: Parcelamento?
  end

  def validate_hourly_rate_schema
    required_fields = ['rate']
    validate_required_fields(required_fields)
    validate_numeric_field('rate')
    validate_numeric_field('estimated_hours', required: false)
    validate_numeric_field('minimum_hours', required: false)
    # TD: Horas total
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
    # TD: Sucumbencia no contrato - True or False
    # TD: Sucumbencia esperada?
  end

  def validate_consultation_fee_schema
    required_fields = ['amount']
    validate_required_fields(required_fields)
    validate_numeric_field('amount')
    validate_numeric_field('duration_minutes', required: false)
    # TD: Consulta -> Contrato simplificado?
  end

  def validate_performance_fee_schema
    validate_array_field('milestones', required: false)
  end

  def validate_required_fields(fields)
    fields.each do |field|
      errors.add(:details, "#{field} is required") if details[field].blank?
      # TD: Entender melhor isso
    end
  end

  def validate_numeric_field(field, required: true)
    # TD: Type Safety manual -> Estudar Mais
    return unless required || details[field].present?

    value = details[field]
    return unless value.present? && !value.is_a?(Numeric)

    errors.add(:details, "#{field} must be a number")
  end

  def validate_array_field(field, required: true)
    return unless required || details[field].present?

    value = details[field]
    return unless value.present? && !value.is_a?(Array)

    errors.add(:details, "#{field} must be an array")
  end
end
