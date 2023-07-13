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
          include: %i[tributary perdlaunch recommendation profile_customers
                      powers jobs checklists]
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
          :rate_parceled_exfield, :folder, :initial_atendee, :note, :checklist, :pending_document, :office_id,
          documents_attributes: %i[id document_type],
          tributary_attributes: %i[id compensation craft lawsuit projection],
          perdlaunch_attributes: %i[id compensation craft lawsuit projection perd_number
                                    shipping_date payment_date status value responsible perd_style],
          checklists_attributes: %i[id description],
          powers_attributes: %i[id description category],
          profile_customer_ids: []
        )
      end
    end
  end
end
