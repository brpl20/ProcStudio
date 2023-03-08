# frozen_string_literal: true

class OfficeEmail < ApplicationRecord
  belongs_to :office
  belongs_to :email
end
