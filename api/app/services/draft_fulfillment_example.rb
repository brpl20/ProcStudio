# frozen_string_literal: true

# Example service demonstrating how to use draft fulfillment when creating records
# This is a reference implementation - adapt for your specific models
class DraftFulfillmentExample
  # Example: Creating a new Work from draft data
  def self.create_work_from_draft(params, user:, session_id: nil)
    ActiveRecord::Base.transaction do
      # Create the work
      work = Work.create!(params)
      
      # If there was a draft for this creation, fulfill it
      if session_id
        Work.fulfill_draft_after_create(
          work,
          session_id: session_id,
          form_type: 'work_creation',
          user: user
        )
      end
      
      work
    end
  end

  # Example: Creating a new Job from draft data
  def self.create_job_from_draft(params, user:, session_id: nil)
    ActiveRecord::Base.transaction do
      # Create the job
      job = Job.create!(params)
      
      # Fulfill the draft if it exists
      if session_id
        draft = Draft.find_draft_for_new_record(
          form_type: 'job_creation',
          user: user,
          team: job.team,
          session_id: session_id
        )
        
        draft&.fulfill!(job)
      end
      
      job
    end
  end

  # Example: Updating existing record and fulfilling its draft
  def self.update_and_fulfill_draft(record, params, form_type:)
    ActiveRecord::Base.transaction do
      # Update the record
      record.update!(params)
      
      # Mark any draft as fulfilled
      record.mark_draft_fulfilled!(form_type, team: record.team)
      
      record
    end
  end

  # Example: Controller action that uses draft fulfillment
  class ExampleController
    def create
      # Check if there's a draft session
      session_id = params[:draft_session_id]
      
      # If session_id exists, try to load draft data
      if session_id.present?
        draft = Draft.find_draft_for_new_record(
          form_type: 'work_creation',
          user: current_user,
          team: current_team,
          session_id: session_id
        )
        
        # Merge draft data with submitted params if draft exists
        if draft
          work_params = work_params.merge(draft.data.except('session_id'))
        end
      end
      
      # Create the work and fulfill the draft
      work = DraftFulfillmentExample.create_work_from_draft(
        work_params,
        user: current_user,
        session_id: session_id
      )
      
      render json: { 
        success: true, 
        message: 'Work created successfully',
        data: work,
        draft_fulfilled: session_id.present?
      }
    end
  end
end