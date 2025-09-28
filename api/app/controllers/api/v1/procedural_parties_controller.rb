# frozen_string_literal: true

module Api
  module V1
    class ProceduralPartiesController < BackofficeController
      before_action :set_procedure
      before_action :set_procedural_party, only: [:show, :update, :destroy]
      before_action :perform_authorization

      after_action :verify_authorized

      def index
        parties = @procedure.procedural_parties.includes(:partyable).ordered

        parties = parties.where(party_type: params[:party_type]) if params[:party_type].present?

        render json: ProceduralPartySerializer.new(
          parties,
          meta: {
            total_count: parties.count,
            plaintiffs_count: @procedure.plaintiffs.count,
            defendants_count: @procedure.defendants.count
          }
        ), status: :ok
      end

      def show
        render json: ProceduralPartySerializer.new(@procedural_party), status: :ok
      end

      def create
        procedural_party = @procedure.procedural_parties.build(procedural_party_params)

        if procedural_party.save
          render json: ProceduralPartySerializer.new(procedural_party), status: :created
        else
          render json: { errors: procedural_party.errors.full_messages }, status: :unprocessable_content
        end
      end

      def update
        if @procedural_party.update(procedural_party_params)
          render json: ProceduralPartySerializer.new(@procedural_party), status: :ok
        else
          render json: { errors: @procedural_party.errors.full_messages }, status: :unprocessable_content
        end
      end

      def destroy
        @procedural_party.destroy
        head :no_content
      end

      # Custom endpoints
      def set_primary
        party = @procedure.procedural_parties.find(params[:party_id])

        # Remove primary from other parties of same type
        @procedure.procedural_parties
          .where(party_type: party.party_type, is_primary: true)
          .where.not(id: party.id)
          .update_all(is_primary: false)

        party.update!(is_primary: true)

        render json: ProceduralPartySerializer.new(party), status: :ok
      end

      def reorder
        params[:order].each_with_index do |id, index|
          @procedure.procedural_parties.find(id).update(position: index + 1)
        end

        head :no_content
      end

      private

      def set_procedure
        work = team_scoped(Work).find(params[:work_id])
        @procedure = work.procedures.find(params[:procedure_id])
      end

      def set_procedural_party
        @procedural_party = @procedure.procedural_parties.find(params[:id])
      end

      def procedural_party_params
        params.expect(
          procedural_party: [:party_type,
                             :partyable_type,
                             :partyable_id,
                             :name,
                             :cpf_cnpj,
                             :oab_number,
                             :is_primary,
                             :position,
                             :represented_by,
                             :notes]
        )
      end

      def perform_authorization
        authorize ProceduralParty
      end
    end
  end
end
