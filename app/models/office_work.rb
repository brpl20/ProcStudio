# frozen_string_literal: true

class OfficeWork < ApplicationRecord
  belongs_to :office
  belongs_to :work
end
