# frozen_string_literal: true

# == Schema Information
#
# Table name: jobs
#
#  id                  :bigint           not null, primary key
#  comment             :string
#  deadline            :date             not null
#  deleted_at          :datetime
#  description         :string
#  priority            :string
#  status              :string
#  title               :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  created_by_id       :bigint
#  profile_customer_id :bigint
#  team_id             :bigint           not null
#  work_id             :bigint
#
# Indexes
#
#  index_jobs_on_created_by_id        (created_by_id)
#  index_jobs_on_deleted_at           (deleted_at)
#  index_jobs_on_profile_customer_id  (profile_customer_id)
#  index_jobs_on_team_id              (team_id)
#  index_jobs_on_work_id              (work_id)
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => users.id)
#  fk_rails_...  (team_id => teams.id)
#
class JobSerializer
  include JSONAPI::Serializer

  def self.avatar_url_for(profile)
    return unless profile.avatar.attached?

    Rails.application.routes.url_helpers.rails_blob_url(profile.avatar, only_path: true)
  end

  private_class_method :avatar_url_for

  attributes :title, :description, :deadline, :status, :priority, :created_by_id

  attribute :customer_id, &:profile_customer_id

  attribute :responsible_id do |object|
    object.assignees.first&.id
  end

  attribute :work_number do |object|
    object.work.number if object.work.present?
  end

  # Return all assignee IDs
  attribute :assignee_ids do |object|
    object.assignees.pluck(:id)
  end

  # For index action - include avatar URLs
  attribute :assignees_summary, if: proc { |_, options| options[:action] == 'index' } do |object|
    object.assignees.limit(3).map do |assignee|
      {
        id: assignee.id,
        name: assignee.name,
        last_name: assignee.last_name,
        avatar_url: avatar_url_for(assignee)
      }
    end
  end

  # Return all supervisor IDs
  attribute :supervisor_ids do |object|
    object.supervisors.pluck(:id)
  end

  # Return all collaborator IDs
  attribute :collaborator_ids do |object|
    object.job_user_profiles.where(role: 'collaborator').pluck(:user_profile_id)
  end

  # Detailed information for show action
  attribute :assignees, if: proc { |_, options| options[:action] == 'show' } do |object|
    object.assignees.map do |assignee|
      {
        id: assignee.id,
        name: assignee.name,
        last_name: assignee.last_name,
        role: 'assignee',
        avatar_url: avatar_url_for(assignee)
      }
    end
  end

  attribute :supervisors, if: proc { |_, options| options[:action] == 'show' } do |object|
    object.supervisors.map do |supervisor|
      {
        id: supervisor.id,
        name: supervisor.name,
        last_name: supervisor.last_name,
        role: 'supervisor',
        avatar_url: avatar_url_for(supervisor)
      }
    end
  end

  attribute :collaborators, if: proc { |_, options| options[:action] == 'show' } do |object|
    collaborator_profiles = UserProfile.joins(:job_user_profiles)
                              .where(job_user_profiles: { job_id: object.id, role: 'collaborator' })
    collaborator_profiles.map do |collaborator|
      {
        id: collaborator.id,
        name: collaborator.name,
        last_name: collaborator.last_name,
        role: 'collaborator',
        avatar_url: avatar_url_for(collaborator)
      }
    end
  end

  attribute :profile_customer, if: proc { |_, options| options[:action] == 'show' } do |object|
    next unless object.profile_customer

    {
      id: object.profile_customer.id,
      customer_type: object.profile_customer.customer_type,
      name: object.profile_customer.name,
      last_name: object.profile_customer.last_name,
      gender: object.profile_customer.gender,
      rg: object.profile_customer.rg,
      cpf: object.profile_customer.cpf,
      cnpj: object.profile_customer.cnpj,
      nationality: object.profile_customer.nationality,
      civil_status: object.profile_customer.civil_status,
      capacity: object.profile_customer.capacity,
      profession: object.profile_customer.profession,
      company: object.profile_customer.company,
      birth: object.profile_customer.birth&.to_json,
      mother_name: object.profile_customer.mother_name,
      number_benefit: object.profile_customer.number_benefit,
      status: object.profile_customer.status,
      document: object.profile_customer.document,
      nit: object.profile_customer.nit,
      inss_password: object.profile_customer.inss_password,
      customer_id: object.profile_customer.customer_id
    }
  end

  attributes :work, if: proc { |_, options| options[:action] == 'show' } do |object|
    next unless object.work

    {
      id: object.work.id,
      work_status: object.work.work_status,
      number: object.work.number,
      rate_parceled_exfield: object.work.rate_parceled_exfield,
      folder: object.work.folder,
      initial_atendee: object.work.initial_atendee,
      note: object.work.note,
      extra_pending_document: object.work.extra_pending_document,
      created_at: object.work.created_at.iso8601,
      updated_at: object.work.updated_at.iso8601,
      civel_area: object.work.civel_area,
      social_security_areas: object.work.social_security_areas,
      laborite_areas: object.work.laborite_areas,
      tributary_areas: object.work.tributary_areas,
      other_description: object.work.other_description,
      compensations_five_years: object.work.compensations_five_years,
      compensations_service: object.work.compensations_service,
      lawsuit: object.work.lawsuit,
      gain_projection: object.work.gain_projection
    }
  end

  attributes :deleted do |object|
    object.deleted_at.present?
  end

  # Comments count for index
  attribute :comments_count do |object|
    object.comments.size
  end

  # Latest comment for index
  attribute :latest_comment, if: proc { |_, options| options[:action] == 'index' } do |object|
    latest = object.comments.recent_first.first
    next unless latest

    {
      id: latest.id,
      content: latest.content.truncate(100),
      created_at: latest.created_at.iso8601,
      author: {
        id: latest.user_profile.id,
        name: latest.user_profile.full_name,
        avatar_url: avatar_url_for(latest.user_profile)
      }
    }
  end

  # Full comments for show action
  attribute :comments, if: proc { |_, options| options[:action] == 'show' } do |object|
    object.comments.recent_first.map do |comment|
      {
        id: comment.id,
        content: comment.content,
        created_at: comment.created_at.iso8601,
        updated_at: comment.updated_at.iso8601,
        author: {
          id: comment.user_profile.id,
          name: comment.user_profile.full_name,
          avatar_url: avatar_url_for(comment.user_profile)
        }
      }
    end
  end
end
