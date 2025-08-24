# frozen_string_literal: true

# == Schema Information
#
# Table name: teams
#
#  id         :bigint           not null, primary key
#  deleted_at :datetime
#  name       :string           not null
#  settings   :jsonb
#  subdomain  :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_teams_on_deleted_at  (deleted_at)
#  index_teams_on_subdomain   (subdomain) UNIQUE
#
class TeamSerializer
  include JSONAPI::Serializer

  attributes :name, :subdomain
end
