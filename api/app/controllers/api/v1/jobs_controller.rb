# frozen_string_literal: true

module Api
  module V1
    class JobsController < BackofficeController
      include JsonResponseConcern
      include AttachmentTransferable

      before_action :retrieve_job, only: [:show, :update]
      before_action :perform_authorization, except: [:update]

      after_action :verify_authorized

      rescue_from ActiveRecord::RecordNotFound do |_exception|
        render_not_found('Job')
      end

      rescue_from Pundit::NotAuthorizedError do |_exception|
        render_unauthorized
      end

      def index
        jobs = team_scoped(Job).with_full_associations.all

        filter_by_deleted_params.each do |key, value|
          next if value.blank?

          jobs = jobs.public_send("filter_by_#{key}", value.strip)
        end

        serialized_data = JobSerializer.new(
          jobs,
          meta: {
            total_count: jobs.offset(nil).limit(nil).count
          },
          params: { action: 'index' }
        ).serializable_hash

        render_success(
          message: 'Jobs listados com sucesso',
          data: serialized_data[:data],
          meta: serialized_data[:meta]
        )
      end

      def show
        @job = Job.with_full_associations.find(@job.id)

        render_success(
          message: 'Job encontrado com sucesso',
          data: JobSerializer.new(
            @job,
            { params: { action: 'show' } }
          ).serializable_hash[:data]
        )
      end

      def create
        job = build_job
        if job.save
          assign_users_to_job(job, params[:job])
          render_create_success(job)
        else
          render_create_error(job)
        end
      rescue StandardError => e
        render_error(
          message: e.message || 'Erro ao processar requisição',
          errors: [e.message]
        )
      end

      def update
        authorize @job, :update?, policy_class: Admin::JobPolicy

        if @job.update(jobs_params)
          # Atualizar assignees se fornecidos
          assign_users_to_job(@job, params[:job], update: true)

          render_success(
            message: 'Job atualizado com sucesso',
            data: JobSerializer.new(@job).serializable_hash[:data]
          )
        else
          render_error(
            message: @job.errors.full_messages.first || 'Erro ao atualizar job',
            errors: @job.errors.full_messages
          )
        end
      end

      def destroy
        if destroy_fully?
          job = team_scoped(Job).with_deleted.find(params[:id])
          job.destroy_fully!
          render json: {
            success: true,
            message: 'Job excluído permanentemente com sucesso'
          }, status: :ok
        else
          retrieve_job
          if @job.destroy
            render_success(message: 'Job excluído com sucesso')
          else
            render_error(
              message: 'Erro ao excluir job',
              errors: @job.errors.full_messages
            )
          end
        end
      rescue ActiveRecord::RecordNotFound
        render_not_found('Job')
      end

      def restore
        job = team_scoped(Job).with_deleted.find(params[:id])
        authorize job, :restore?, policy_class: Admin::JobPolicy

        if job.recover
          render json: {
            success: true,
            message: 'Job restaurado com sucesso',
            data: JobSerializer.new(job).serializable_hash[:data]
          }, status: :ok
        else
          render(
            status: :bad_request,
            json: {
              success: false,
              message: job.errors.full_messages.first || 'Erro ao restaurar job',
              errors: job.errors.full_messages
            }
          )
        end
      rescue ActiveRecord::RecordNotFound
        render_not_found('Job')
      end

      def upload_attachment
        retrieve_job

        unless params[:attachment].present?
          return render_error(
            message: 'Arquivo não fornecido',
            errors: ['Attachment file is required']
          )
        end

        begin
          file_metadata = @job.upload_attachment(
            params[:attachment],
            user_profile: current_user.user_profile,
            description: params[:description],
            document_date: params[:document_date]
          )

          render_success(
            message: 'Anexo enviado com sucesso',
            data: {
              id: @job.id,
              file_metadata_id: file_metadata.id,
              filename: file_metadata.filename,
              url: file_metadata.url,
              byte_size: file_metadata.byte_size,
              content_type: file_metadata.content_type
            }
          )
        rescue StandardError => e
          Rails.logger.error "Job attachment upload failed: #{e.message}"
          render_error(
            message: 'Erro ao fazer upload do anexo',
            errors: [e.message]
          )
        end
      end

      def remove_attachment
        retrieve_job

        begin
          @job.delete_attachment(params[:attachment_id])
          render_success(
            message: 'Anexo removido com sucesso',
            data: { id: @job.id, attachment_id: params[:attachment_id] }
          )
        rescue ActiveRecord::RecordNotFound
          render_not_found('Anexo')
        rescue StandardError => e
          render_error(
            message: 'Erro ao remover anexo',
            errors: [e.message]
          )
        end
      end

      private

      def retrieve_job
        @job = team_scoped(Job).find(params[:id])
      end

      def jobs_params
        params.expect(
          job: [:title,
                :description,
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
        remove_existing_assignments(job, job_params) if update
        assign_role_users(job, job_params[:assignee_ids], 'assignee') if job_params[:assignee_ids].present?
        assign_role_users(job, job_params[:supervisor_ids], 'supervisor') if job_params[:supervisor_ids].present?
        assign_role_users(job, job_params[:collaborator_ids], 'collaborator') if job_params[:collaborator_ids].present?
      end

      def build_job
        job = Job.new(jobs_params)
        job.team = current_team
        job.created_by = @current_user
        job
      end

      def render_create_success(job)
        render_success(
          message: 'Job criado com sucesso',
          data: JobSerializer.new(job).serializable_hash[:data],
          status: :created
        )
      end

      def render_create_error(job)
        render_error(
          message: job.errors.full_messages.first || 'Erro ao criar job',
          errors: job.errors.full_messages
        )
      end

      def remove_existing_assignments(job, job_params)
        job.job_user_profiles.where(role: 'assignee').destroy_all if job_params[:assignee_ids].present?
        job.job_user_profiles.where(role: 'supervisor').destroy_all if job_params[:supervisor_ids].present?
        job.job_user_profiles.where(role: 'collaborator').destroy_all if job_params[:collaborator_ids].present?
      end

      def assign_role_users(job, user_ids, role)
        team_user_profiles = find_team_user_profiles(job, user_ids)
        team_user_profiles.each do |user_profile|
          job.job_user_profiles.find_or_create_by(
            user_profile: user_profile,
            role: role
          )
        end

        log_invalid_user_ids(job, user_ids, team_user_profiles) if role == 'assignee'
      end

      def find_team_user_profiles(job, user_ids)
        UserProfile.joins(:user).where(
          id: user_ids,
          users: { team_id: job.team_id }
        )
      end

      def log_invalid_user_ids(job, user_ids, team_user_profiles)
        invalid_ids = user_ids.map(&:to_i) - team_user_profiles.pluck(:id)
        return unless invalid_ids.any?

        Rails.logger.warn "UserProfile IDs #{invalid_ids} ignorados: não pertencem ao team #{job.team&.name}"
      end
    end
  end
end
