# frozen_string_literal: true

# == Schema Information
#
# Table name: wiki_page_revisions
#
#  id             :bigint(8)        not null, primary key
#  wiki_page_id   :bigint(8)        not null
#  title          :string           not null
#  content        :text
#  version_number :integer          not null
#  created_by_id  :bigint(8)        not null
#  change_summary :text
#  diff_data      :json
#  deleted_at     :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class WikiPageRevision < ApplicationRecord
  include DeletedFilterConcern

  belongs_to :wiki_page
  belongs_to :created_by, class_name: 'Admin'

  validates :title, presence: true
  validates :version_number, presence: true, uniqueness: { scope: :wiki_page_id }

  scope :ordered, -> { order(version_number: :desc) }

  def diff_with_previous
    previous = wiki_page.revisions.where('version_number < ?', version_number).ordered.first
    return nil unless previous

    {
      title: { from: previous.title, to: title },
      content: generate_content_diff(previous.content, content)
    }
  end

  private

  def generate_content_diff(old_content, new_content)
    # Simple diff implementation - in production, use a proper diff library
    {
      old: old_content,
      new: new_content,
      changes: calculate_changes(old_content, new_content)
    }
  end

  def calculate_changes(old_content, new_content)
    # Placeholder for diff algorithm
    # In production, use libraries like diffy or diff-lcs
    {
      additions: new_content.to_s.length - old_content.to_s.length,
      deletions: 0
    }
  end
end
