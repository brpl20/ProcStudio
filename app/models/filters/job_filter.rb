# frozen_string_literal: true

class JobFilter
  class << self
    def retrieve_job(id)
      Job.find(id)
    end

    def retrieve_jobs
      Job.all
    end
  end
end
