# frozen_string_literal: true

module Api
  module V1
    class JobCommentsController < BackofficeController
      before_action :retrieve_job
      before_action :retrieve_comment, only: [:update, :destroy]
      before_action :perform_authorization

      after_action :verify_authorized

      def index
        comments = @job.comments
                     .includes(user_profile: { avatar_attachment: :blob })
                     .recent_first

        render json: {
          success: true,
          message: 'Comentários listados com sucesso',
          data: JobCommentSerializer.new(comments).serializable_hash[:data]
        }, status: :ok
      end

      def create
        comment = @job.comments.build(comment_params)
        comment.user_profile = current_user.user_profile

        if comment.save
          render json: {
            success: true,
            message: 'Comentário criado com sucesso',
            data: JobCommentSerializer.new(comment).serializable_hash[:data]
          }, status: :created
        else
          render json: {
            success: false,
            message: comment.errors.full_messages.first || 'Erro ao criar comentário',
            errors: comment.errors.full_messages
          }, status: :bad_request
        end
      end

      def update
        if @comment.update(comment_params)
          render json: {
            success: true,
            message: 'Comentário atualizado com sucesso',
            data: JobCommentSerializer.new(@comment).serializable_hash[:data]
          }, status: :ok
        else
          render json: {
            success: false,
            message: @comment.errors.full_messages.first || 'Erro ao atualizar comentário',
            errors: @comment.errors.full_messages
          }, status: :bad_request
        end
      end

      def destroy
        if @comment.destroy
          render json: {
            success: true,
            message: 'Comentário excluído com sucesso'
          }, status: :ok
        else
          render json: {
            success: false,
            message: 'Erro ao excluir comentário',
            errors: @comment.errors.full_messages
          }, status: :bad_request
        end
      end

      private

      def retrieve_job
        @job = team_scoped(Job).find(params[:job_id])
      rescue ActiveRecord::RecordNotFound
        render json: {
          success: false,
          message: 'Job não encontrado',
          errors: ['Job não encontrado']
        }, status: :not_found
      end

      def retrieve_comment
        @comment = @job.comments.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: {
          success: false,
          message: 'Comentário não encontrado',
          errors: ['Comentário não encontrado']
        }, status: :not_found
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
