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
        job.created_by = @current_user

        if job.save
          # Processar diferentes tipos de assignees após salvar
          assign_users_to_job(job, params[:job])

          render json: JobSerializer.new(job), status: :created
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
          # Atualizar assignees se fornecidos
          assign_users_to_job(@job, params[:job], update: true)

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
        params.expect(
          job: [:description,
                :deadline,
                :status,
                :priority,
                :comment,
                :profile_customer_id,
                :work_id]
        )
      end

      def perform_authorization
        authorize [:admin, :job], :"#{action_name}?"
      end

      def assign_users_to_job(job, job_params, update: false)
        # Se é update, remove assignees existentes apenas dos tipos que estão sendo atualizados
        if update
          job.job_user_profiles.where(role: 'assignee').destroy_all if job_params[:assignee_ids].present?
          job.job_user_profiles.where(role: 'supervisor').destroy_all if job_params[:supervisor_ids].present?
          job.job_user_profiles.where(role: 'collaborator').destroy_all if job_params[:collaborator_ids].present?
        end

        # Adicionar assignees (com validação de team)
        if job_params[:assignee_ids].present?
          team_user_profiles = UserProfile.joins(:user).where(
            id: job_params[:assignee_ids],
            users: { team_id: job.team_id }
          )

          team_user_profiles.each do |user_profile|
            job.job_user_profiles.find_or_create_by(
              user_profile: user_profile,
              role: 'assignee'
            )
          end

          # Verificar se algum ID foi ignorado (não pertence ao team)
          invalid_ids = job_params[:assignee_ids].map(&:to_i) - team_user_profiles.pluck(:id)
          if invalid_ids.any?
            Rails.logger.warn "UserProfile IDs #{invalid_ids} ignorados: não pertencem ao team #{job.team&.name}"
          end
        end

        # Adicionar supervisors (com validação de team)
        if job_params[:supervisor_ids].present?
          team_user_profiles = UserProfile.joins(:user).where(
            id: job_params[:supervisor_ids],
            users: { team_id: job.team_id }
          )

          team_user_profiles.each do |user_profile|
            job.job_user_profiles.find_or_create_by(
              user_profile: user_profile,
              role: 'supervisor'
            )
          end
        end

        # Adicionar collaborators (com validação de team)
        return if job_params[:collaborator_ids].blank?

        team_user_profiles = UserProfile.joins(:user).where(
          id: job_params[:collaborator_ids],
          users: { team_id: job.team_id }
        )

        team_user_profiles.each do |user_profile|
          job.job_user_profiles.find_or_create_by(
            user_profile: user_profile,
            role: 'collaborator'
          )
        end
      end
    end
  end
end
