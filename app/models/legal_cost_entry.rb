# frozen_string_literal: true

# == Schema Information
#
# Table name: legal_cost_entries
#
#  id             :bigint           not null, primary key
#  amount         :decimal(10, 2)
#  cost_type      :string           not null
#  description    :text
#  due_date       :date
#  estimated      :boolean          default(FALSE)
#  metadata       :jsonb
#  name           :string           not null
#  paid           :boolean          default(FALSE)
#  payment_date   :date
#  payment_method :string
#  receipt_number :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  legal_cost_id  :bigint           not null
#
# Indexes
#
#  index_legal_cost_entries_on_cost_type               (cost_type)
#  index_legal_cost_entries_on_due_date                (due_date)
#  index_legal_cost_entries_on_legal_cost_id           (legal_cost_id)
#  index_legal_cost_entries_on_legal_cost_id_and_paid  (legal_cost_id,paid)
#  index_legal_cost_entries_on_payment_date            (payment_date)
#
# Foreign Keys
#
#  fk_rails_...  (legal_cost_id => legal_costs.id)
#
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
    taxa_recursal: 'Taxa de Recurso',
    deposito_recursal: 'Depósito Recursal',
    preparo: 'Preparo',
    porte_remessa: 'Porte de Remessa e Retorno',
    outros: 'Outros'
  }.freeze

  validates :cost_type, presence: true, inclusion: { in: BRAZILIAN_COST_TYPES.keys.map(&:to_s) }
  validates :name, presence: true
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # Scopes
  scope :paid, -> { where(paid: true) }
  scope :pending, -> { where(paid: false) }
  scope :overdue, -> { pending.where(due_date: ...Date.current) }
  scope :upcoming, ->(days = 30) { pending.where('due_date BETWEEN ? AND ?', Date.current, Date.current + days.days) }
  scope :estimated, -> { where(estimated: true) }
  scope :confirmed, -> { where(estimated: false) }
  scope :by_type, ->(type) { where(cost_type: type) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_due_date, -> { order(:due_date) }

  # Callbacks
  before_validation :set_defaults

  def mark_as_paid!(payment_date: Date.current, receipt: nil, method: nil)
    update!(
      paid: true,
      payment_date: payment_date,
      receipt_number: receipt,
      payment_method: method,
      estimated: false # When paid, it's no longer estimated
    )
  end

  def mark_as_unpaid!
    update!(
      paid: false,
      payment_date: nil,
      receipt_number: nil,
      payment_method: nil
    )
  end

  def overdue?
    !paid? && due_date.present? && due_date < Date.current
  end

  def upcoming?(days = 30)
    !paid? && due_date.present? && due_date.between?(Date.current, Date.current + days.days)
  end

  def days_until_due
    return nil if due_date.blank?

    (due_date - Date.current).to_i
  end

  def days_overdue
    return 0 unless overdue?

    (Date.current - due_date).to_i
  end

  def display_name
    BRAZILIAN_COST_TYPES[cost_type.to_sym] || name
  end

  def status
    if paid?
      'paid'
    elsif overdue?
      'overdue'
    elsif upcoming?(7)
      'urgent'
    elsif upcoming?
      'upcoming'
    else
      'pending'
    end
  end

  def status_color
    case status
    when 'paid' then 'green'
    when 'overdue' then 'red'
    when 'urgent' then 'orange'
    when 'upcoming' then 'yellow'
    else 'gray'
    end
  end

  private

  def set_defaults
    self.estimated = false if estimated.nil?
    self.paid = false if paid.nil?
  end
end
