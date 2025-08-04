# frozen_string_literal: true

# == Schema Information
#
# Table name: wiki_categories
#
#  id          :bigint(8)        not null, primary key
#  name        :string           not null
#  slug        :string           not null
#  description :text
#  team_id     :bigint(8)        not null
#  parent_id   :bigint(8)
#  position    :integer          default(0)
#  color       :string
#  icon        :string
#  deleted_at  :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class WikiCategory < ApplicationRecord
  include DeletedFilterConcern

  belongs_to :team
  belongs_to :parent, class_name: 'WikiCategory', optional: true

  has_many :children, class_name: 'WikiCategory', foreign_key: 'parent_id', dependent: :destroy
  has_many :wiki_page_categories, dependent: :destroy
  has_many :pages, through: :wiki_page_categories, source: :wiki_page

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: { scope: :team_id }
  validates :slug, format: { with: /\A[a-z0-9-]+\z/, message: 'only lowercase letters, numbers and dashes allowed' }

  before_validation :generate_slug, if: -> { slug.blank? && name.present? }

  scope :root_categories, -> { where(parent_id: nil) }
  scope :ordered, -> { order(:position, :name) }

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

  def all_pages
    # Get all pages from this category and all subcategories
    category_ids = [id] + children.pluck(:id)
    WikiPage.joins(:wiki_page_categories)
            .where(wiki_page_categories: { wiki_category_id: category_ids })
            .distinct
  end

  private

  def generate_slug
    self.slug = name.parameterize
  end
end
