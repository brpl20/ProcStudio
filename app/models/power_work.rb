# frozen_string_literal: true

class PowerWork < ApplicationRecord
  belongs_to :power
  belongs_to :work
end
