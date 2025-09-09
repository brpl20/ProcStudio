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

class Job < ApplicationRecord
  include DeletedFilterConcern

  acts_as_paranoid

  belongs_to :team
  belongs_to :work, optional: true
  belongs_to :profile_customer, optional: true
  belongs_to :created_by, class_name: 'User'

  has_many :job_user_profiles, dependent: :destroy
  has_many :user_profiles, through: :job_user_profiles
  has_many :assignees, -> { where(job_user_profiles: { role: 'assignee' }) },
           through: :job_user_profiles, source: :user_profile
  has_many :supervisors, -> { where(job_user_profiles: { role: 'supervisor' }) },
           through: :job_user_profiles, source: :user_profile
  has_many :job_comments, dependent: :destroy
  has_many :comments, class_name: 'JobComment', dependent: :destroy

  validate :work_same_team, if: -> { work.present? }
  validate :customer_same_team, if: -> { profile_customer.present? }
  validate :at_least_one_assignee

  after_create :ensure_creator_as_assignee

  enum :status, {
    pending: 'pending',
    delayed: 'delayed',
    finished: 'finished'
  }

  after_find :check_and_update_status

  # Métodos helper
  def primary_assignee
    assignees.first
  end

  def all_members
    user_profiles
  end

  def add_assignee(user_profile, role: 'assignee')
    # Validar se o user_profile pertence ao mesmo team
    unless user_profile&.user&.team == team
      raise ArgumentError, "UserProfile deve pertencer ao mesmo team do job (#{team&.name})"
    end

    job_user_profiles.find_or_create_by(user_profile: user_profile, role: role)
  end

  def remove_assignee(user_profile)
    job_user_profiles.find_by(user_profile: user_profile)&.destroy
  end

  def user_involved?(user_or_user_profile)
    user_profile = user_or_user_profile.is_a?(User) ? user_or_user_profile.user_profile : user_or_user_profile
    return false unless user_profile

    user_profiles.include?(user_profile)
  end

  def user_role(user_or_user_profile)
    user_profile = user_or_user_profile.is_a?(User) ? user_or_user_profile.user_profile : user_or_user_profile
    return nil unless user_profile

    job_user_profiles.find_by(user_profile: user_profile)&.role
  end

  def assign_to_user(user, role: 'assignee')
    return unless user&.user_profile

    add_assignee(user.user_profile, role: role)
  end

  # Verificar se pode adicionar um user_profile ao job
  def can_add_user_profile?(user_profile)
    return false unless user_profile&.user&.team
    return false unless user_profile.user.team == team
    return false if user_involved?(user_profile)

    true
  end

  # Obter apenas members do mesmo team
  def team_members
    user_profiles.joins(:user).where(users: { team_id: team_id })
  end

  # Contar roles específicos
  delegate :count, to: :assignees, prefix: true

  delegate :count, to: :supervisors, prefix: true

  # Verificar se tem pelo menos um assignee válido do team
  def valid_assignees?
    assignees.joins(:user).exists?(users: { team_id: team_id })
  end

  private

  def check_and_update_status
    return unless status == 'pending'
    return unless deadline < Time.zone.today

    self.status = 'delayed'
    save!
  end

  def work_same_team
    errors.add(:work, 'deve ser do mesmo team') unless work.team == team
  end

  def customer_same_team
    customer_teams = profile_customer.customer.teams
    errors.add(:profile_customer, 'deve pertencer ao mesmo team') unless customer_teams.include?(team)
  end

  def at_least_one_assignee
    # Só valida se o job já foi persistido (after_create já rodou)
    return unless persisted?

    errors.add(:base, 'Job deve ter pelo menos um responsável (assignee)') if assignees.empty?
  end

  def ensure_creator_as_assignee
    # Se não tem nenhum assignee, adiciona o criador como assignee
    return unless assignees.empty? && created_by&.user_profile.present?

    add_assignee(created_by.user_profile, role: 'assignee')
  end
end
