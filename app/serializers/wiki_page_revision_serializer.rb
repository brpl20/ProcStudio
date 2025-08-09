# frozen_string_literal: true

class WikiPageRevisionSerializer < ActiveModel::Serializer
  attributes :id, :title, :content, :version_number, :change_summary,
             :created_at, :diff_data

  belongs_to :wiki_page
  belongs_to :created_by, serializer: AdminSerializer

  def diff_data
    object.diff_data if instance_options[:include_diff]
  end
end
