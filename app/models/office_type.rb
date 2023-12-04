# frozen_string_literal: true

class OfficeType < ApplicationRecord
  validates :description, uniqueness: { case_sensitive: true }, presence: true
end
