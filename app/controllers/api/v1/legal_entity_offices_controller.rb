# frozen_string_literal: true

module Api
  module V1
    class LegalEntityOfficesController < BackofficeController
      before_action :retrieve_office, only: %i[show update destroy]
      # before_action :perform_authorization, except: %i[]

      # after_action :verify_authorized

      def index
        offices = LegalEntityOffice.all

        render json: { 
          data: offices.map { |office| office_with_relationships(office) }
        }, status: :ok
      end

      def create
        office = LegalEntityOffice.new(office_params)

        if office.save
          render json: { 
            data: office_with_relationships(office)
          }, status: :created
        else
          render(
            status: :bad_request,
            json: { errors: [{ code: office.errors.full_messages }] }
          )
        end
      rescue StandardError => e
        render(
          status: :bad_request,
          json: { errors: [{ code: e.message }] }
        )
      end

      def show
        render json: { 
          data: office_with_relationships(@office)
        }, status: :ok
      end

      def update
        if @office.update(office_params)
          render json: { 
            data: office_with_relationships(@office)
          }, status: :ok
        else
          render(
            status: :bad_request,
            json: { errors: [{ code: @office.errors.full_messages }] }
          )
        end
      end

      def destroy
        @office.destroy
        head :no_content
      end

      private

      def office_params
        params.require(:legal_entity_office).permit(
          :legal_entity_id, :team_id, :oab_id, :inscription_number, 
          :society_link, :legal_specialty
        )
      end

      def office_with_relationships(office)
        {
          id: office.id,
          legal_entity_id: office.legal_entity_id,
          team_id: office.team_id,
          oab_id: office.oab_id,
          inscription_number: office.inscription_number,
          society_link: office.society_link,
          legal_specialty: office.legal_specialty,
          partnerships: office.legal_entity_office_relationships.map do |partnership|
            {
              id: partnership.id,
              lawyer_id: partnership.lawyer_id,
              lawyer_name: "#{partnership.lawyer.name} #{partnership.lawyer.last_name}",
              partnership_type: partnership.partnership_type,
              ownership_percentage: partnership.ownership_percentage,
              created_at: partnership.created_at,
              updated_at: partnership.updated_at
            }
          end,
          legal_entity: {
            id: office.legal_entity.id,
            name: office.legal_entity.name,
            cnpj: office.legal_entity.cnpj
          }
        }
      end

      def retrieve_office
        @office = LegalEntityOffice.find(params[:id])
      end

      def perform_authorization
        authorize [:admin, :legal_entity_office], "#{action_name}?".to_sym
      end
    end
  end
end