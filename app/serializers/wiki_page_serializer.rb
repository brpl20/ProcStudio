# frozen_string_literal: true

class WikiPageSerializer < ActiveModel::Serializer
  attributes :id, :title, :slug, :content, :position, :is_published, :is_locked,
             :published_at, :created_at, :updated_at, :full_path, :metadata

  belongs_to :team
  belongs_to :created_by, serializer: AdminSerializer
  belongs_to :updated_by, serializer: AdminSerializer
  belongs_to :parent, serializer: WikiPageSerializer
  has_many :children, serializer: WikiPageSerializer
  has_many :categories, serializer: WikiCategorySerializer

  def full_path
    object.full_path
  end
end
