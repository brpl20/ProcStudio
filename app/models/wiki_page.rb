# frozen_string_literal: true

# == Schema Information
#
# Table name: wiki_pages
#
#  id            :bigint(8)        not null, primary key
#  title         :string           not null
#  slug          :string           not null
#  content       :text
#  team_id       :bigint(8)        not null
#  created_by_id :bigint(8)        not null
#  updated_by_id :bigint(8)        not null
#  parent_id     :bigint(8)
#  position      :integer          default(0)
#  is_published  :boolean          default(FALSE)
#  is_locked     :boolean          default(FALSE)
#  metadata      :json
#  published_at  :datetime
#  deleted_at    :datetime
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
class WikiPage < ApplicationRecord
  include DeletedFilterConcern

  belongs_to :team
  belongs_to :created_by, class_name: 'Admin'
  belongs_to :updated_by, class_name: 'Admin'
  belongs_to :parent, class_name: 'WikiPage', optional: true

  has_many :children, class_name: 'WikiPage', foreign_key: 'parent_id', dependent: :destroy
  has_many :revisions, class_name: 'WikiPageRevision', dependent: :destroy
  has_many :wiki_page_categories, dependent: :destroy
  has_many :categories, through: :wiki_page_categories, source: :wiki_category

  validates :title, presence: true
  validates :slug, presence: true, uniqueness: { scope: :team_id }
  validates :slug, format: { with: /\A[a-z0-9-]+\z/, message: 'only lowercase letters, numbers and dashes allowed' }

  before_validation :generate_slug, if: -> { slug.blank? && title.present? }
  after_save :create_revision, if: :saved_change_to_content?

  scope :published, -> { where(is_published: true) }
  scope :draft, -> { where(is_published: false) }
  scope :locked, -> { where(is_locked: true) }
  scope :unlocked, -> { where(is_locked: false) }
  scope :root_pages, -> { where(parent_id: nil) }
  scope :ordered, -> { order(:position, :title) }

  def publish!
    update!(is_published: true, published_at: Time.current)
  end

  def unpublish!
    update!(is_published: false, published_at: nil)
  end

  def lock!(admin)
    update!(is_locked: true, updated_by: admin)
  end

  def unlock!(admin)
    update!(is_locked: false, updated_by: admin)
  end

  def current_revision
    revisions.order(version_number: :desc).first
  end

  def revision_at(version_number)
    revisions.find_by(version_number: version_number)
  end

  def revert_to!(version_number, admin)
    revision = revision_at(version_number)
    return false unless revision

    update!(
      title: revision.title,
      content: revision.content,
      updated_by: admin
    )
  end

  def breadcrumbs
    ancestors = []
    current = self
    while current.parent
      ancestors.unshift(current.parent)
      current = current.parent
    end
    ancestors << self
  end

  def full_path
    breadcrumbs.map(&:slug).join('/')
  end

  private

  def generate_slug
    self.slug = title.parameterize
  end

  def create_revision
    next_version = (revisions.maximum(:version_number) || 0) + 1

    revisions.create!(
      title: title,
      content: content,
      version_number: next_version,
      created_by: updated_by,
      change_summary: metadata['change_summary']
    )
  end
end
