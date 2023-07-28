# frozen_string_literal: true

module Api
  module V1
    class WorksController < BackofficeController
      before_action :set_work, only: %i[show update destroy]

      def index
        works = Work.all

        render json: WorkSerializer.new(
          works,
          meta: {
            total_count: works.offset(nil).limit(nil).count
          }
        ), status: :ok
      end

      def create
        work = Work.new(work_params)
        if work.save
          Works::CreateDocumentService.call(work)
          render json: work, status: :created
        else
          render(
            status: :bad_request,
            json: { errors: [{ code: work.errors.full_messages }] }
          )
        end
      rescue StandardError => e
        render(
          status: :bad_request,
          json: { errors: [{ code: e }] }
        )
      end

      def update
        if @work.update(work_params)
          render json: WorkSerializer.new(
            @work
          ), status: :ok
        else
          render(
            status: :bad_request,
            json: { errors: [{ code: @work.errors.full_messages }] }
          )
        end
      end

      def show
        render json: WorkSerializer.new(
          @work,
          include: %i[profile_customers
                      powers jobs]
        ), status: :ok
      end

      private

      def set_work
        @work = Work.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        head :not_found
      end

      def work_params
        params.require(:work).permit(
          :procedure, :subject, :action, :number, :rate_percentage, :rate_percentage_exfield, :rate_fixed,
          :rate_parceled_exfield, :folder, :initial_atendee, :note, :checklist, :extra_pending_document,
          documents_attributes: %i[id document_type],
          pending_documents_attributes: %i[id description],
          recommendations_attributes: %i[id percentage commition profile_customer_id],
          power_ids: [],
          profile_customer_ids: [],
          profile_admin_ids: [],
          office_ids: []
        )
      end
    end
  end
end
