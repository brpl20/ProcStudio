# frozen_string_literal: true

class TributarySerializer
  include JSONAPI::Serializer
  attributes :compensation, :craft, :lawsuit, :projection
end
