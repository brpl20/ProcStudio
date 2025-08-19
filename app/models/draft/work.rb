# frozen_string_literal: true

# == Schema Information
#
# Table name: draft_works
#
#  id         :bigint           not null, primary key
#  deleted_at :datetime
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  work_id    :bigint           not null
#
# Indexes
#
#  index_draft_works_on_deleted_at  (deleted_at)
#  index_draft_works_on_work_id     (work_id)
#
# Foreign Keys
#
#  fk_rails_...  (work_id => works.id)
#

class Draft::Work < ApplicationRecord
  include DeletedFilterConcern

  acts_as_paranoid

  belongs_to :work, class_name: '::Work'

  validates :name, uniqueness: { case_sensitive: false }, presence: true

  def work_id=(id)
    self.work = Work.find(id)
  end

  delegate :procedure, :subject, :number, :civel_area, :social_security_areas, :laborite_areas,
           :other_description, :laborite_areas, :tributary_areas, :physical_lawyer, :responsible_lawyer,
           :partner_lawyer, :intern, :bachelor, :initial_atendee, :note, :folder, :rate_parceled_exfield,
           :extra_pending_document, :compensations_five_years, :compensations_service, :lawsuit,
           :gain_projection, :physical_lawyer, :procedures, :honorary, :offices, :profile_customers,
           :profile_admins, :powers, :recommendations, :jobs, :pending_documents, :documents, to: :work
end
