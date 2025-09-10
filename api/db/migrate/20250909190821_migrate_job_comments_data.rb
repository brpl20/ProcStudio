# frozen_string_literal: true

class MigrateJobCommentsData < ActiveRecord::Migration[8.0]
  def up
    # Migrate existing comments to job_comments table
    Job.unscoped.find_each do |job|
      next if job.comment.blank?

      # Try to find the creator's user_profile or use the first assignee
      user_profile = job.created_by&.user_profile || job.assignees.first

      # Skip if no user_profile found
      next unless user_profile

      JobComment.create!(
        job: job,
        user_profile: user_profile,
        content: job.comment,
        created_at: job.created_at,
        updated_at: job.updated_at
      )
    end

    # After migration, you can remove the comment column
    # remove_column :jobs, :comment
  end

  def down
    # If you need to rollback, restore the comments to the jobs table
    JobComment.find_each do |comment|
      job = comment.job
      # Only update if job doesn't have a comment already
      job.update_column(:comment, comment.content) if job.comment.blank?
    end

    # Delete all job_comments
    JobComment.destroy_all
  end
end
