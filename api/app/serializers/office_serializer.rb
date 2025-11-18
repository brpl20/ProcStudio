# frozen_string_literal: true

# == Schema Information
#
# Table name: offices
#
#  id                                       :bigint           not null, primary key
#  accounting_type                          :string
#  cnpj                                     :string
#  deleted_at                               :datetime
#  foundation                               :date
#  logo_s3_key                              :string
#  name                                     :string
#  number_of_quotes(Total number of quotes) :integer          default(0)
#  oab_inscricao                            :string
#  oab_link                                 :string
#  oab_status                               :string
#  proportional                             :boolean          default(FALSE), not null
#  quote_value(Value per quote in BRL)      :decimal(10, 2)
#  site                                     :string
#  society                                  :string
#  created_at                               :datetime         not null
#  updated_at                               :datetime         not null
#  created_by_id                            :bigint
#  deleted_by_id                            :bigint
#  oab_id                                   :string
#  team_id                                  :bigint           not null
#
# Indexes
#
#  index_offices_on_accounting_type  (accounting_type)
#  index_offices_on_created_by_id    (created_by_id)
#  index_offices_on_deleted_at       (deleted_at)
#  index_offices_on_deleted_by_id    (deleted_by_id)
#  index_offices_on_logo_s3_key      (logo_s3_key)
#  index_offices_on_team_id          (team_id)
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => users.id)
#  fk_rails_...  (deleted_by_id => users.id)
#  fk_rails_...  (team_id => teams.id)
#
class OfficeSerializer
  include JSONAPI::Serializer

  attributes :name, :cnpj, :site, :quote_value, :number_of_quotes, :total_quotes_value, :proportional

  # Always include attachments
  attribute :logo_url do |object|
    object.logo_url
  end

  attribute :social_contracts_with_metadata do |object|
    object.social_contracts.map do |contract|
      {
        id: contract.id,
        filename: contract.filename,
        content_type: contract.content_type,
        byte_size: contract.byte_size,
        uploaded_at: contract.uploaded_at,
        url: contract.url,
        uploaded_by: contract.uploaded_by&.full_name
      }
    end
  end

  attributes :society, :foundation, :addresses, :phones, :emails, :bank_accounts, :works,
             :accounting_type, :oab_id, :oab_inscricao, :oab_link, :oab_status,
             :formatted_total_quotes_value,
             if: proc { |_, options| options[:action] == 'show' }

  # Include user_offices with compensations for detailed views
  attribute :user_offices, if: proc { |_, options| options[:action] == 'show' } do |object|
    object.user_offices.includes(:user, :compensations).map do |user_office|
      UserOfficeSerializer.new(user_office).serializable_hash[:data][:attributes]
    end
  end

  attribute :city do |object|
    object.addresses.main_addresses.first&.city
  end

  attribute :state do |object|
    object.addresses.main_addresses.first&.state
  end

  attribute :deleted do |object|
    object.deleted_at.present?
  end

  # Expose new FormatterOffices methods for detailed views
  attribute :partners_info, if: proc { |_, options| options[:action] == 'show' } do |object|
    formatter = DocxServices::FormatterOffices.new(object)
    formatter.partners_info
  end

  attribute :partners_compensation, if: proc { |_, options| options[:action] == 'show' } do |object|
    formatter = DocxServices::FormatterOffices.new(object)
    formatter.partners_compensation
  end

  attribute :is_proportional, if: proc { |_, options| options[:action] == 'show' } do |object|
    formatter = DocxServices::FormatterOffices.new(object)
    formatter.is_proportional
  end
end
