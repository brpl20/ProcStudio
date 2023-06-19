# frozen_string_literal: true

class Job < ApplicationRecord
  has_many :job_works, dependent: :destroy
  has_many :works, through: :job_works
end
