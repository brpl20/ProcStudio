# frozen_string_literal: true

module Api
  module V1
    class LegalEntityOfficeRelationshipsController < BackofficeController
      before_action :retrieve_office
      before_action :retrieve_relationship, only: %i[update destroy]
      # before_action :perform_authorization, except: %i[]

      # after_action :verify_authorized

      def create
        relationship = @office.legal_entity_office_relationships.new(relationship_params)

        if relationship.save
          render json: { 
            data: format_relationship(relationship)
          }, status: :created
        else
          render(
            status: :bad_request,
            json: { errors: [{ code: relationship.errors.full_messages }] }
          )
        end
      rescue StandardError => e
        render(
          status: :bad_request,
          json: { errors: [{ code: e.message }] }
        )
      end

      def update
        if @relationship.update(relationship_params)
          render json: { 
            data: format_relationship(@relationship)
          }, status: :ok
        else
          render(
            status: :bad_request,
            json: { errors: [{ code: @relationship.errors.full_messages }] }
          )
        end
      end

      def destroy
        @relationship.destroy
        head :no_content
      end

      private

      def relationship_params
        params.require(:partnership).permit(
          :lawyer_id, :partnership_type, :ownership_percentage
        )
      end

      def format_relationship(relationship)
        {
          id: relationship.id,
          legal_entity_office_id: relationship.legal_entity_office_id,
          lawyer_id: relationship.lawyer_id,
          lawyer_name: "#{relationship.lawyer.name} #{relationship.lawyer.last_name}",
          lawyer_cpf: relationship.lawyer.cpf,
          partnership_type: relationship.partnership_type,
          partnership_type_display: case relationship.partnership_type
                                   when 'socio' then 'Sócio'
                                   when 'associado' then 'Associado'  
                                   when 'socio_de_servico' then 'Sócio de Serviço'
                                   else relationship.partnership_type
                                   end,
          ownership_percentage: relationship.ownership_percentage,
          created_at: relationship.created_at,
          updated_at: relationship.updated_at
        }
      end

      def retrieve_office
        @office = LegalEntityOffice.find(params[:legal_entity_office_id])
      end

      def retrieve_relationship
        @relationship = @office.legal_entity_office_relationships.find(params[:id])
      end

      def perform_authorization
        authorize [:admin, :legal_entity_office_relationship], "#{action_name}?".to_sym
      end
    end
  end
end