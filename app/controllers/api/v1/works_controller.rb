# frozen_string_literal: true

module Api
  module V1
    class WorksController < BackofficeController
      before_action :load_active_storage_url_options unless Rails.env.production?

      before_action :set_work, only: %i[show update convert_documents_to_pdf]
      before_action :perform_authorization, except: %i[update restore]

      after_action :verify_authorized

      def index
        works = current_team ? Work.by_team(current_team) : Work.all
        works = works.includes(
          :profile_customers,
          :current_configuration,
          :powers,
          :recommendations,
          :jobs,
          :documents,
          :pending_documents
        )

        filtering_params.each do |key, value|
          next unless value.present?

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

      def create
        work = Work.new(work_params.except(:office_ids, :profile_admin_ids, :work_configuration))
        work.created_by_id = current_user.id
        work.team = current_team

        if work.save
          # Create initial configuration if offices or lawyers are provided
          if params[:work][:office_ids].present? || params[:work][:profile_admin_ids].present? || params[:work][:work_configuration].present?
            create_work_configuration(work)
          end
          
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

        if @work.update(work_params.except(:office_ids, :profile_admin_ids, :work_configuration))
          # Update configuration if offices or lawyers are provided
          if params[:work][:office_ids].present? || params[:work][:profile_admin_ids].present? || params[:work][:work_configuration].present?
            update_work_configuration(@work)
          end
          
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
        if destroy_fully?
          Work.with_deleted.find(params[:id]).destroy_fully!
        else
          set_work
          @work.destroy
        end
      end

      def restore
        work = Work.with_deleted.find(params[:id])
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
        @work = Work.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        head :not_found
      end

      def work_params
        params.require(:work).permit(
          :procedure, :subject, :number, :folder, :initial_atendee, :note, :extra_pending_document,
          :civel_area, :social_security_areas, :laborite_areas, :tributary_areas, :other_description,
          :compensations_five_years, :compensations_service, :lawsuit, :gain_projection, :physical_lawyer,
          :responsible_lawyer, :partner_lawyer, :intern, :bachelor, :rate_parceled_exfield, :status, :team_id,
          documents_attributes: %i[id document_type profile_customer_id],
          pending_documents_attributes: %i[id description profile_customer_id],
          recommendations_attributes: %i[id percentage commission profile_customer_id],
          honorary_attributes: %i[id fixed_honorary_value parcelling_value honorary_type percent_honorary_value parcelling work_prev],
          power_ids: [],
          profile_customer_ids: [],
          profile_admin_ids: [], # Keep for backwards compatibility
          office_ids: [], # Keep for backwards compatibility
          procedures: [],
          work_configuration: [
            offices: [:id, lawyers: []],
            independent_lawyers: [:id, :role],
            roles: {},
            fee_distribution: {}
          ]
        )
      end
      
      def create_work_configuration(work)
        config_params = configuration_params
        WorkConfigurationService.create_initial_configuration(
          work,
          offices: config_params[:offices],
          lawyers: config_params[:independent_lawyers],
          roles: config_params[:roles],
          fee_distribution: config_params[:fee_distribution],
          admin: current_user
        )
      end
      
      def update_work_configuration(work)
        config_params = configuration_params
        WorkConfigurationService.update_configuration(
          work,
          offices: config_params[:offices],
          lawyers: config_params[:independent_lawyers],
          roles: config_params[:roles],
          fee_distribution: config_params[:fee_distribution],
          admin: current_user
        )
      end
      
      def configuration_params
        # Support both new format and legacy format
        if params[:work][:work_configuration].present?
          params[:work][:work_configuration]
        else
          # Legacy format support
          {
            offices: params[:work][:office_ids]&.map { |id| { id: id } },
            independent_lawyers: params[:work][:profile_admin_ids]&.map { |id| { id: id } }
          }
        end
      end

      def filtering_params
        params.permit(:customer_id, :deleted)
      end

      def convert_docs_params
        params.permit(approved_documents: [])
      end

      def perform_authorization
        authorize [:admin, :work], "#{action_name}?".to_sym
      end
    end
  end
end
