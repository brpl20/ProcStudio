# frozen_string_literal: true

class RepresentSerializer
  include JSONAPI::Serializer

  # Defina apenas os atributos que você quer incluir no retorno
  attributes :id, :profile_customer_id, :representor_id
end
