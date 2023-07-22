# frozen_string_literal: true

class Work < ApplicationRecord
  has_one :tributary, dependent: :destroy
  has_one :perdlaunch, dependent: :destroy
  has_many :work_updates, dependent: :destroy
  has_many :recommendation, dependent: :destroy

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

  belongs_to :office

  has_many :jobs

  enum procedure: {
    administrative: 'administrative',
    judicial: 'judicial',
    extrajudicial: 'extrajudicial'
  }
  accepts_nested_attributes_for :tributary, :perdlaunch, :documents,
                                :checklists, reject_if: :all_blank, allow_destroy: true
end
