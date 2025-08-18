# frozen_string_literal: true

module Api
  module V1
    class JobsController < BackofficeController
      before_action :retrieve_job, only: [:show, :update]
      before_action :perform_authorization, except: [:update]

      after_action :verify_authorized

      def index
        jobs = team_scoped(Job).all

        filter_by_deleted_params.each do |key, value|
          next if value.blank?

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
        job.team = current_team
        job.created_by_id = current_user&.id
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
        if destroy_fully?
          job = team_scoped(Job).with_deleted.find(params[:id])
          job.destroy_fully!
        else
          retrieve_job
          @job.destroy
        end
      end

      def restore
        job = team_scoped(Job).with_deleted.find(params[:id])
        authorize job, :restore?, policy_class: Admin::WorkPolicy

        if job.recover
          render json: JobSerializer.new(
            job
          ), status: :ok
        else
          render(
            status: :bad_request,
            json: { errors: [{ code: job.errors.full_messages }] }
          )
        end
      end

      private

      def retrieve_job
        @job = team_scoped(Job).find(params[:id])
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
        authorize [:admin, :job], :"#{action_name}?"
      end
    end
  end
end
