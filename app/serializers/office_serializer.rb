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
#  name                                     :string
#  number_of_quotes(Total number of quotes) :integer          default(0)
#  oab_inscricao                            :string
#  oab_link                                 :string
#  oab_status                               :string
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

  attributes :name, :cnpj, :site, :quote_value, :number_of_quotes, :total_quotes_value

  # Always include attachments
  attributes :logo_url, :social_contracts_with_metadata

  attributes :society, :foundation, :addresses, :phones, :emails, :bank_accounts, :works,
             :accounting_type, :oab_id, :oab_inscricao, :oab_link, :oab_status,
             :formatted_total_quotes_value,
             if: proc { |_, options| options[:action] == 'show' }

  attribute :city do |object|
    object.addresses.main_addresses.first&.city
  end

  attribute :state do |object|
    object.addresses.main_addresses.first&.state
  end

  attribute :deleted do |object|
    object.deleted_at.present?
  end
end
