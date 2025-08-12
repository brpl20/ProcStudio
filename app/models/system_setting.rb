# == Schema Information
#
# Table name: system_settings
#
#  id          :bigint(8)        not null, primary key
#  key         :string           not null
#  value       :decimal(10, 2)
#  year        :integer          not null
#  description :text
#  active      :boolean          default(TRUE)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class SystemSetting < ApplicationRecord
  validates :key, presence: true
  validates :year, presence: true
  validates :value, presence: true, numericality: { greater_than: 0 }
  validates :key, uniqueness: { scope: :year }

  scope :active, -> { where(active: true) }
  scope :current_year, -> { where(year: Date.current.year) }
  scope :by_key, ->(key) { where(key: key) }

  # Constantes para as chaves do sistema
  MINIMUM_WAGE = 'minimum_wage'.freeze
  INSS_CEILING = 'inss_ceiling'.freeze

  # Método helper para buscar configuração atual
  def self.current_value_for(key)
    active.current_year.by_key(key).first&.value
  end

  # Métodos específicos para valores importantes
  def self.current_minimum_wage
    current_value_for(MINIMUM_WAGE) || 1320.00 # Valor padrão 2024
  end

  def self.current_inss_ceiling
    current_value_for(INSS_CEILING) || 7507.49 # Valor padrão 2024
  end

  def self.setup_defaults_for_year(year)
    return if exists?(year: year)

    create!([
              {
                key: MINIMUM_WAGE,
                value: 1320.00, # Valor padrão, deve ser atualizado manualmente
                year: year,
                description: "Salário mínimo nacional para o ano #{year}",
                active: true
              },
              {
                key: INSS_CEILING,
                value: 7507.49, # Valor padrão, deve ser atualizado manualmente
                year: year,
                description: "Teto de contribuição do INSS para o ano #{year}",
                active: true
              }
            ])
  end
end
