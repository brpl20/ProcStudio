# frozen_string_literal: true

# == Schema Information
#
# Table name: offices
#
#  id                    :bigint           not null, primary key
#  accounting_type       :string
#  cnpj                  :string
#  deleted_at            :datetime
#  foundation            :date
#  name                  :string
#  oab                   :string
#  site                  :string
#  society               :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  office_type_id        :bigint           not null
#  responsible_lawyer_id :integer
#  team_id               :bigint           not null
#
# Indexes
#
#  index_offices_on_accounting_type        (accounting_type)
#  index_offices_on_deleted_at             (deleted_at)
#  index_offices_on_office_type_id         (office_type_id)
#  index_offices_on_responsible_lawyer_id  (responsible_lawyer_id)
#  index_offices_on_team_id                (team_id)
#
# Foreign Keys
#
#  fk_rails_...  (office_type_id => office_types.id)
#  fk_rails_...  (team_id => teams.id)
#
class OfficeSerializer
  include JSONAPI::Serializer

  attributes :name, :cnpj, :city, :site, :responsible_lawyer_id

  attributes :oab, :society, :foundation, :zip_code, :street, :number, :neighborhood,
             :state, :user_profiles, :phones, :emails, :bank_accounts, :works,
             :accounting_type, if: proc { |_, options| options[:action] == 'show' }

  attribute :office_type_description do |object|
    object.office_type.description
  end

  attribute :deleted do |object|
    object.deleted_at.present?
  end
end
