# frozen_string_literal: true

module Api
  module V1
    class WorksController < BackofficeController
      before_action :load_active_storage_url_options unless Rails.env.production?

      before_action :set_work, only: [:show, :update, :convert_documents_to_pdf]
      before_action :perform_authorization, except: [:update, :restore]

      after_action :verify_authorized

      def index
        works = team_scoped(Work).includes(
          :profile_customers,
          :user_profiles,
          :law_area,
          :powers,
          :recommendations,
          :jobs,
          :documents,
          :pending_documents
        ).all

        filtering_params.each do |key, value|
          next if value.blank?

          works = works.public_send("filter_by_#{key}", value)
        end

        works = works.order(id: :desc).limit(params[:limit])

        render json: WorkSerializer.new(
          works,
          meta: {
            total_count: works.size
          }
        ), status: :ok
      end

      def show
        render json: WorkSerializer.new(
          @work,
          params: { action: 'show' }
        ), status: :ok
      end

      def create
        work_attributes = work_params

        # Debug: Log the parameters to see what's being received
        Rails.logger.info "Work params: #{work_attributes.inspect}"

        work = Work.new(work_attributes)
        work.team = current_team
        work.created_by_id = current_user&.id

        if work.save
          Works::CreateDocumentService.call(work)

          # Reload to get all associations
          work.reload

          # Get the serialized data without the outer "data" wrapper
          serialized = WorkSerializer.new(work).serializable_hash

          render json: {
            success: true,
            message: 'Work created successfully',
            data: serialized[:data] # Extract just the data part, not the wrapper
          }, status: :created
        else
          render json: {
            success: false,
            message: work.errors.full_messages.first || 'Failed to create work',
            errors: work.errors.full_messages
          }, status: :unprocessable_entity
        end
      rescue StandardError => e
        render json: {
          success: false,
          message: e.message,
          errors: [e.message]
        }, status: :bad_request
      end

      def update
        authorize @work, :update?, policy_class: Admin::WorkPolicy

        if @work.update(work_params)
          Works::CreateDocumentService.call(@work) if truthy_param?(:regenerate_documents)

          # Reload to get updated associations
          @work.reload
          serialized = WorkSerializer.new(@work).serializable_hash

          render json: {
            success: true,
            message: 'Work updated successfully',
            data: serialized[:data]
          }, status: :ok
        else
          render json: {
            success: false,
            message: @work.errors.full_messages.first || 'Failed to update work',
            errors: @work.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def destroy
        if destroy_fully?
          work = team_scoped(Work).with_deleted.find(params[:id])
          work.destroy_fully!
        else
          set_work
          @work.destroy
        end
      end

      def restore
        work = team_scoped(Work).with_deleted.find(params[:id])
        authorize work, :restore?, policy_class: Admin::WorkPolicy

        if work.recover
          render json: WorkSerializer.new(
            work
          ), status: :ok
        else
          render(
            status: :bad_request,
            json: { errors: [{ code: work.errors.full_messages }] }
          )
        end
      end

      def convert_documents_to_pdf
        approved_ids = convert_docs_params[:approved_documents] || []
        documents = @work.documents.where(id: approved_ids)

        return render json: { error: 'Nenhum documento encontrado' }, status: :not_found if documents.empty?

        documents.each do |document|
          Works::DocxToPdfConverterService.call(document)
        end

        render json: { message: 'Documentos convertidos com sucesso!' }, status: :ok
      end

      private

      def set_work
        @work = team_scoped(Work).find(params[:id])
      rescue ActiveRecord::RecordNotFound
        head :not_found
      end

      def work_params
        params.expect(
          work: [:law_area_id, :number, :folder, :initial_atendee, :note, :extra_pending_document,
                 :other_description, :compensations_five_years, :compensations_service, :lawsuit, :gain_projection,
                 :physical_lawyer, :responsible_lawyer, :partner_lawyer, :intern, :bachelor, :rate_parceled_exfield,
                 :work_status,
                 { documents_attributes: [:id, :document_type, :profile_customer_id, :name, :description, :_destroy],
                   pending_documents_attributes: [:id, :description, :profile_customer_id, :name, :due_date, :_destroy],
                   recommendations_attributes: [:id, :percentage, :commission, :profile_customer_id, :title, :description, :priority, :due_date, :_destroy],
                   procedures_attributes: [
                     :id, :procedure_type, :law_area_id, :number, :city, :state, :system, :competence,
                     :start_date, :end_date, :procedure_class, :responsible, :claim_value, :conviction_value,
                     :received_value, :status, :justice_free, :conciliation, :priority, :priority_type, :notes, :_destroy,
                     { procedural_parties_attributes: [:id, :party_type, :partyable_type, :partyable_id, :name,
                                                       :cpf_cnpj, :oab_number, :is_primary, :represented_by, :notes, :_destroy],
                       honoraries_attributes: [:id, :name, :description, :status, :honorary_type, :fixed_honorary_value,
                                               :percent_honorary_value, :parcelling, :parcelling_value, :_destroy,
                                               { components_attributes: [:id, :component_type, :active, :position, :details, :_destroy] }] }
                   ],
                   honoraries_attributes: [
                     :id, :name, :description, :status, :honorary_type, :fixed_honorary_value,
                     :percent_honorary_value, :parcelling, :parcelling_value, :work_prev, :_destroy,
                     { components_attributes: [:id, :component_type, :active, :position, :details, :_destroy],
                       legal_cost_attributes: [:id, :client_responsible, :include_in_invoices, :admin_fee_percentage, :_destroy,
                                               { entries_attributes: [:id, :cost_type, :name, :description, :amount, :estimated,
                                                                      :paid, :due_date, :payment_date, :receipt_number,
                                                                      :payment_method, :metadata, :_destroy] }] }
                   ],
                   customer_works_attributes: [:id, :profile_customer_id, :_destroy],
                   user_profile_works_attributes: [:id, :user_profile_id, :_destroy],
                   power_ids: [],
                   profile_customer_ids: [],
                   user_profile_ids: [],
                   office_ids: [] }]
        )
      end

      def filtering_params
        params.permit(:customer_id, :deleted)
      end

      def convert_docs_params
        params.permit(approved_documents: [])
      end

      def perform_authorization
        authorize [:admin, :work], :"#{action_name}?"
      end
    end
  end
end
