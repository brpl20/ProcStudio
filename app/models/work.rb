# frozen_string_literal: true

class Work < ApplicationRecord
  has_many :customer_works, dependent: :destroy
  has_many :profile_customers, through: :customer_works

  has_many :profile_admin_works, through: :profile_admin_works
  has_many :profile_admins, dependent: :destroy

  has_many :checklist_document_works, dependent: :destroy
  has_many :checklist_documents, through: :checklist_document_works

  has_many :checklist_works, dependent: :destroy
  has_many :checklists, through: :checklist_works

  has_many :power_works, dependent: :destroy
  has_many :powers, through: :power_works

  has_many :documents, dependent: :destroy

  has_many :pending_documents, dependent: :destroy

  has_many :office_works, dependent: :destroy
  has_many :offices, through: :office_works

  has_many :recommendations, dependent: :destroy

  has_many :jobs

  enum procedure: {
    administrative: 'administrative',
    judicial: 'judicial',
    extrajudicial: 'extrajudicial'
  }
  accepts_nested_attributes_for :documents, :pending_documents, :recommendations, reject_if: :all_blank, allow_destroy: true
end
