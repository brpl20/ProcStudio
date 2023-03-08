# frozen_string_literal: true

class OfficePhone < ApplicationRecord
  belongs_to :office
  belongs_to :phone
end
