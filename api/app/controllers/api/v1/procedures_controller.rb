# frozen_string_literal: true

module Api
  module V1
    class ProceduresController < BackofficeController
      before_action :set_work
      before_action :set_procedure, only: [:show, :update, :destroy]
      before_action :perform_authorization

      after_action :verify_authorized

      def index
        procedures = @work.procedures.includes(
          :law_area,
          :procedural_parties,
          :honoraries,
          :children
        )

        procedures = apply_filters(procedures)
        procedures = procedures.order(created_at: :desc)

        render json: ProcedureSerializer.new(
          procedures,
          meta: { total_count: procedures.count }
        ), status: :ok
      end

      def show
        render json: ProcedureSerializer.new(
          @procedure,
          include: [:procedural_parties, :honoraries, :children]
        ), status: :ok
      end

      def create
        procedure = @work.procedures.build(procedure_params)

        if procedure.save
          render json: ProcedureSerializer.new(procedure), status: :created
        else
          render json: { errors: procedure.errors.full_messages }, status: :unprocessable_content
        end
      end

      def update
        if @procedure.update(procedure_params)
          render json: ProcedureSerializer.new(@procedure), status: :ok
        else
          render json: { errors: @procedure.errors.full_messages }, status: :unprocessable_content
        end
      end

      def destroy
        @procedure.destroy
        head :no_content
      end

      # Custom endpoints
      def create_child
        parent = @work.procedures.find(params[:procedure_id])
        child = parent.children.build(procedure_params)
        child.work = @work

        if child.save
          render json: ProcedureSerializer.new(child), status: :created
        else
          render json: { errors: child.errors.full_messages }, status: :unprocessable_content
        end
      end

      def tree
        procedures = @work.root_procedures.includes(:descendants)

        render json: {
          data: build_tree(procedures)
        }, status: :ok
      end

      def financial_summary
        procedure = @work.procedures.find(params[:procedure_id])

        render json: {
          data: {
            claim_value: procedure.claim_value,
            conviction_value: procedure.conviction_value,
            received_value: procedure.received_value,
            pending_value: (procedure.conviction_value || 0) - (procedure.received_value || 0),
            has_financial_values: procedure.has_financial_values?
          }
        }, status: :ok
      end

      private

      def set_work
        @work = team_scoped(Work).find(params[:work_id])
      end

      def set_procedure
        @procedure = @work.procedures.find(params[:id])
      end

      def procedure_params
        params.expect(
          procedure: [:procedure_type,
                      :law_area_id,
                      :number,
                      :city,
                      :state,
                      :system,
                      :competence,
                      :start_date,
                      :end_date,
                      :procedure_class,
                      :responsible,
                      :claim_value,
                      :conviction_value,
                      :received_value,
                      :status,
                      :justice_free,
                      :conciliation,
                      :priority,
                      :priority_type,
                      :notes,
                      :parent_id,
                      { procedural_parties_attributes: [
                        :id,
                        :party_type,
                        :partyable_type,
                        :partyable_id,
                        :name,
                        :cpf_cnpj,
                        :oab_number,
                        :is_primary,
                        :represented_by,
                        :notes,
                        :_destroy
                      ] }]
        )
      end

      def apply_filters(procedures)
        procedures = procedures.where(procedure_type: params[:procedure_type]) if params[:procedure_type].present?
        procedures = procedures.where(status: params[:status]) if params[:status].present?
        procedures = procedures.where(system: params[:system]) if params[:system].present?
        procedures = procedures.where(competence: params[:competence]) if params[:competence].present?
        procedures = procedures.with_priority if params[:priority] == 'true'
        procedures
      end

      def build_tree(procedures)
        procedures.map do |procedure|
          {
            id: procedure.id,
            procedure_type: procedure.procedure_type,
            number: procedure.number,
            status: procedure.status,
            children: build_tree(procedure.children)
          }
        end
      end

      def perform_authorization
        authorize Procedure
      end
    end
  end
end
