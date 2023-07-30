# frozen_string_literal: true

class Work < ApplicationRecord
  has_many :customer_works, dependent: :destroy
  has_many :profile_customers, through: :customer_works

  has_many :profile_admin_works, dependent: :destroy
  has_many :profile_admins, through: :profile_admin_works

  has_many :power_works, dependent: :destroy
  has_many :powers, through: :power_works

  has_many :documents, dependent: :destroy

  has_many :pending_documents, dependent: :destroy

  has_many :office_works, dependent: :destroy
  has_many :offices, through: :office_works

  has_many :recommendations, dependent: :destroy

  has_many :jobs

  has_many_attached :tributary_files

  has_one :honorary

  enum procedure: {
    administrative: 'administrativo',
    judicial: 'judicial',
    extrajudicial: 'extrajudicial'
  }

  enum subject: {
    administrative_subject: 'administrativo',
    civil: 'civel',
    criminal: 'criminal',
    social_security: 'previdenciario',
    laborite: 'trabalhista',
    tributary: 'tributario',
    tributary_pis: 'tributario_pis_confins',
    others: 'outros'
  }

  enum civel_area: {
    family: 'familia',
    consumer: 'consumidor',
    moral_damages: 'danos morais'
  }

  enum tributary_areas: {
    asphalt: 'asfalto',
    license: 'alvara',
    others_tributary: 'outros'
  }

  enum social_security_areas: {
    retirement_by_time: 'aposentadoria_contribuicao',
    retirement_by_age: 'aposentadoria_idade',
    retirement_by_rural: 'aposentadoria_rural',
    disablement: 'invalidez',
    benefit_review: 'revisão_beneficio',
    administrative_services: 'servicos_administrativos'
  }

  enum laborite_areas: {
    labor_claim: 'reclamatoria_trabalhista'
  }

  accepts_nested_attributes_for :documents, :pending_documents, :recommendations, :honorary, reject_if: :all_blank, allow_destroy: true
end
