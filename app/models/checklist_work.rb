# frozen_string_literal: true

class ChecklistWork < ApplicationRecord
  belongs_to :checklist
  belongs_to :work
end
