# frozen_string_literal: true

class TeamSerializer
  include JSONAPI::Serializer

  attributes :name, :subdomain
end
