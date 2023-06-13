# frozen_string_literal: true

class PerdlaunchSerializer
  include JSONAPI::Serializer
  attributes :compensation, :craft, :lawsuit, :projection, :perd_number,
             :shipping_date, :payment_date, :status, :value, :responsible, :perd_style
end
