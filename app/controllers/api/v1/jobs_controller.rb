# frozen_string_literal: true

module Api
  module V1
    class JobsController < BackofficeController
      before_action :retrieve_job, only: %i[show update destroy]
      before_action :perform_authorization, except: %i[update]

      after_action :verify_authorized

      def index
        jobs = JobFilter.retrieve_jobs

        filter_by_deleted_params.each do |key, value|
          next unless value.present?

          jobs = jobs.public_send("filter_by_#{key}", value.strip)
        end

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
        job.created_by_id = current_user.id
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
        authorize @job, :update?, policy_class: Admin::WorkPolicy

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
        @job.destroy
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

      def perform_authorization
        authorize [:admin, :job], "#{action_name}?".to_sym
      end
    end
  end
end
