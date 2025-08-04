# frozen_string_literal: true

class WikiCategorySerializer < ActiveModel::Serializer
  attributes :id, :name, :slug, :description, :position, :color, :icon,
             :created_at, :updated_at, :full_path

  belongs_to :team
  belongs_to :parent, serializer: WikiCategorySerializer
  has_many :children, serializer: WikiCategorySerializer

  def full_path
    object.full_path
  end
end
