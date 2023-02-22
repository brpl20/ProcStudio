# frozen_string_literal: true

class ProfileAdmin < ApplicationRecord
  belongs_to :admin

  enum :role, %i[lawyer paralegal trainee secretary counter excounter]
  enum :status, %i[active inactive pending]

  has_many :admin_addresses, dependent: :destroy
  has_many :addresses, through: :admin_addresses

  accepts_nested_attributes_for :admin, reject_if: :all_blank
  accepts_nested_attributes_for :admin_addresses, :addresses, reject_if: :all_blank
end
