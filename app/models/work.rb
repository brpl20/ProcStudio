# frozen_string_literal: true

class Work < ApplicationRecord
  has_one :tributary, dependent: :destroy
  has_one :perdlaunch, dependent: :destroy
  has_many :work_updates, dependent: :destroy
  has_many :recommendation, dependent: :destroy

  has_many :customer_works, dependent: :destroy
  has_many :profile_customers, through: :customer_works

  has_many :checklist_document_works, dependent: :destroy
  has_many :checklist_documents, through: :checklist_document_works

  has_many :checklists_works, dependent: :destroy
  has_many :checklists, through: :checklists_works

  has_many :power_works, dependent: :destroy
  has_many :powers, through: :power_works

  has_many :job_works, dependent: :destroy
  has_many :jobs, through: :job_works

  accepts_nested_attributes_for :tributary, :perdlaunch, :checklist_document_works, :checklists_works, :power_works, reject_if: :all_blank, allow_destroy: true
end
