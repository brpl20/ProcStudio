# frozen_string_literal: true

module Api
  module V1
    class JobsController < BackofficeController
      before_action :retrieve_job, only: %i[show update destroy]

      def index
        jobs = JobFilter.retrieve_jobs
        render json: JobSerializer.new(
          jobs,
          meta: {
            total_count: jobs.offset(nil).limit(nil).count
          }
        ), status: :ok
      end

      def show
        render json: JobSerializer.new(
          @job,
          { params: { action: 'show' } }
        ), status: :ok
      end

      def create
        job = Job.new(jobs_params)
        if job.save
          render json: job, status: :created
        else
          render(
            status: :bad_request,
            json: { errors: [{ code: job.errors.full_messages }] }
          )
        end
      rescue StandardError => e
        render(
          status: :bad_request,
          json: { errors: [{ code: e }] }
        )
      end

      def update
        if @job.update(jobs_params)
          render json: JobSerializer.new(
            @job
          ), status: :ok
        else
          render(
            status: :bad_request,
            json: { errors: [{ code: @job.errors.full_messages }] }
          )
        end
      end

      def destroy
        if @job.destroy
          render head :not_found
        else
          render json: { errors: job.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def retrieve_job
        @job = Job.find(params[:id])
      end

      def jobs_params
        params.require(:job).permit(
          :description,
          :deadline,
          :status,
          :priority,
          :comment,
          :profile_customer_id,
          :profile_admin_id,
          :work_id
        )
      end
    end
  end
end
