# frozen_string_literal: true

class DocumentSerializer
  include JSONAPI::Serializer

  attributes :id, :document_type, :work_id, :profile_customer_id, :status, :format

  attribute :original_file_url do |document|
    document.original&.url
  end

  attribute :signed_file_url do |document|
    document.signed&.url
  end

  attribute :created_at do |document|
    document.created_at.iso8601
  end

  def self.simple_serialize(documents)
    documents.map do |document|
      {
        id: document.id,
        document_type: document.document_type,
        work_id: document.work_id,
        profile_customer_id: document.profile_customer_id,
        status: I18n.t(document.status, scope: 'activerecord.attributes.document.statuses'),
        format: document.format,
        sign_source: I18n.t(document.sign_source, scope: 'activerecord.attributes.document.sign_sources'),
        original_file_url: document.original&.url,
        signed_file_url: document.signed&.url,
        created_at: document.created_at.to_date.iso8601
      }
    end
  end
end
