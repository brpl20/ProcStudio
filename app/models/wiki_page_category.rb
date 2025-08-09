# frozen_string_literal: true

# == Schema Information
#
# Table name: wiki_page_categories
#
#  id               :bigint(8)        not null, primary key
#  wiki_page_id     :bigint(8)        not null
#  wiki_category_id :bigint(8)        not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class WikiPageCategory < ApplicationRecord
  belongs_to :wiki_page
  belongs_to :wiki_category

  validates :wiki_page_id, uniqueness: { scope: :wiki_category_id }
end
