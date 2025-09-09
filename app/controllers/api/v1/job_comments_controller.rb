# frozen_string_literal: true

module Api
  module V1
    class JobCommentsController < BackofficeController
      include JsonResponseConcern

      before_action :retrieve_job
      before_action :retrieve_comment, only: [:update, :destroy]
      before_action :perform_authorization

      after_action :verify_authorized

      rescue_from ActiveRecord::RecordNotFound do |_exception|
        render_not_found(action_name.in?(['update', 'destroy']) ? 'Comentário' : 'Job')
      end

      def index
        comments = @job.comments
                     .includes(user_profile: { avatar_attachment: :blob })
                     .recent_first

        render_success(
          message: 'Comentários listados com sucesso',
          data: JobCommentSerializer.new(comments).serializable_hash[:data]
        )
      end

      def create
        comment = @job.comments.build(comment_params)
        comment.user_profile = current_user.user_profile

        if comment.save
          render_success(
            message: 'Comentário criado com sucesso',
            data: JobCommentSerializer.new(comment).serializable_hash[:data],
            status: :created
          )
        else
          render_error(
            message: comment.errors.full_messages.first || 'Erro ao criar comentário',
            errors: comment.errors.full_messages
          )
        end
      end

      def update
        if @comment.update(comment_params)
          render_success(
            message: 'Comentário atualizado com sucesso',
            data: JobCommentSerializer.new(@comment).serializable_hash[:data]
          )
        else
          render_error(
            message: @comment.errors.full_messages.first || 'Erro ao atualizar comentário',
            errors: @comment.errors.full_messages
          )
        end
      end

      def destroy
        if @comment.destroy
          render_success(message: 'Comentário excluído com sucesso')
        else
          render_error(
            message: 'Erro ao excluir comentário',
            errors: @comment.errors.full_messages
          )
        end
      end

      private

      def retrieve_job
        @job = team_scoped(Job).find(params[:job_id])
      end

      def retrieve_comment
        @comment = @job.comments.find(params[:id])
      end

      def comment_params
        params.require(:comment).permit(:content)
      end

      def perform_authorization
        # For update/destroy, we need the actual comment record
        if action_name.in?(['update', 'destroy'])
          authorize @comment, :"#{action_name}?", policy_class: Admin::JobCommentPolicy
        else
          # For index/create, use the admin namespace pattern
          authorize [:admin, :job_comment], :"#{action_name}?"
        end
      end
    end
  end
end
