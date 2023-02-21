# frozen_string_literal: true

class ProfileAdmin < ApplicationRecord
  belongs_to :admin
  enum :role, %i[lawyer paralegal trainee secretary counter excounter]
end
