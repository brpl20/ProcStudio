# frozen_string_literal: true

module Api
  module V1
    class WorksController < BackofficeController
      before_action :load_active_storage_url_options unless Rails.env.production?

      before_action :set_work, only: %i[show update destroy]
      before_action :perform_authorization, except: %i[update]

      after_action :verify_authorized

      def index
        works = Work.includes(
          :profile_customers,
          :profile_admins,
          :powers,
          :recommendations,
          :jobs,
          :documents,
          :pending_documents,
          :work_events
        ).all.order(id: :desc).limit(params[:limit])

        filtering_params.each do |key, value|
          next unless value.present?

          works = works.public_send("filter_by_#{key}", value)
        end

        render json: WorkSerializer.new(
          works,
          meta: {
            total_count: works.size
          }
        ), status: :ok
      end

      def create
        work = Work.new(work_params)
        work.created_by_id = current_user.id
        if work.save
          Works::CreateDocumentService.call(work)
          render json: WorkSerializer.new(work), status: :created
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
        authorize @work, :update?, policy_class: Admin::WorkPolicy

        if @work.update(work_params)
          Works::CreateDocumentService.call(@work) if truthy_param?(:regenerate_documents)
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
          params: { action: 'show' }
        ), status: :ok
      end

      def destroy
        @work.destroy
      end

      private

      def set_work
        @work = Work.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        head :not_found
      end

      def work_params
        params.require(:work).permit(
          :procedure, :subject, :number, :folder, :initial_atendee, :note, :extra_pending_document,
          :civel_area, :social_security_areas, :laborite_areas, :tributary_areas, :other_description,
          :compensations_five_years, :compensations_service, :lawsuit, :gain_projection, :physical_lawyer,
          :responsible_lawyer, :partner_lawyer, :intern, :bachelor, :rate_parceled_exfield,
          documents_attributes: %i[id document_type profile_customer_id],
          pending_documents_attributes: %i[id description profile_customer_id],
          recommendations_attributes: %i[id percentage commission profile_customer_id],
          honorary_attributes: %i[id fixed_honorary_value parcelling_value honorary_type percent_honorary_value parcelling],
          power_ids: [],
          profile_customer_ids: [],
          profile_admin_ids: [],
          office_ids: [],
          procedures: []
        )
      end

      def filtering_params
        params.permit(:customer_id)
      end

      def perform_authorization
        authorize [:admin, :work], "#{action_name}?".to_sym
      end
    end
  end
end
