# frozen_string_literal: true

# == Schema Information
#
# Table name: user_offices
#
#  id                     :bigint           not null, primary key
#  cna_link               :string
#  entry_date             :date
#  is_administrator       :boolean          default(FALSE), not null
#  partnership_percentage :decimal(5, 2)    default(0.0)
#  partnership_type       :string           not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  office_id              :bigint           not null
#  user_id                :bigint           not null
#
# Indexes
#
#  index_user_offices_on_office_id              (office_id)
#  index_user_offices_on_user_id                (user_id)
#  index_user_offices_on_user_id_and_office_id  (user_id,office_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (office_id => offices.id)
#  fk_rails_...  (user_id => users.id)
#
class UserOfficeSerializer
  include JSONAPI::Serializer

  attributes :user_id, :office_id, :partnership_type, :partnership_percentage, 
             :is_administrator, :entry_date

  attribute :compensations do |object|
    object.compensations.order(effective_date: :desc).map do |compensation|
      UserSocietyCompensationSerializer.new(compensation).serializable_hash[:data][:attributes]
    end
  end

  # Include user information for convenience
  attribute :user_name do |object|
    object.user.user_profile&.name || object.user.email
  end

  attribute :user_email do |object|
    object.user.email
  end
end
