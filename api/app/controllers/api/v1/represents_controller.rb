# frozen_string_literal: true

module Api
  module V1
    class RepresentsController < BackofficeController
      include RepresentResponses

      before_action :set_represent, only: [:show, :update, :destroy]
      before_action :set_profile_customer, only: [:index, :create]
      before_action :perform_authorization
      after_action :verify_authorized

      # GET /api/v1/profile_customers/:profile_customer_id/represents
      # GET /api/v1/represents (for all represents in the team)
      def index
        represents = query_service.call(
          profile_customer: @profile_customer,
          filters: filter_params
        )
        represent_index_response(represents)
      end

      # GET /api/v1/represents/:id
      def show
        represent_success_response(
          'Representação encontrada com sucesso',
          Represents::SerializerService.call(@represent, detailed: true)
        )
      end

      # POST /api/v1/profile_customers/:profile_customer_id/represents
      # POST /api/v1/represents
      def create
        represent = build_represent

        if represent.save
          represent_success_response(
            'Representação criada com sucesso',
            Represents::SerializerService.call(represent, detailed: true),
            :created
          )
        else
          represent_error_response(
            'Erro ao criar representação',
            represent.errors.full_messages
          )
        end
      end

      # PATCH/PUT /api/v1/represents/:id
      def update
        if @represent.update(represent_params)
          represent_success_response(
            'Representação atualizada com sucesso',
            Represents::SerializerService.call(@represent, detailed: true)
          )
        else
          represent_error_response(
            'Erro ao atualizar representação',
            @represent.errors.full_messages
          )
        end
      end

      # DELETE /api/v1/represents/:id
      def destroy
        if @represent.destroy
          represent_success_response('Representação removida com sucesso')
        else
          represent_error_response(
            'Erro ao remover representação',
            @represent.errors.full_messages
          )
        end
      end

      # POST /api/v1/represents/:id/deactivate
      def deactivate
        @represent = Represent.find(params[:id])
        status_updater = Represents::StatusUpdaterService.new(@represent)

        if status_updater.deactivate
          represent_success_response(
            'Representação desativada com sucesso',
            Represents::SerializerService.call(@represent)
          )
        else
          represent_error_response(
            'Erro ao desativar representação',
            @represent.errors.full_messages
          )
        end
      end

      # POST /api/v1/represents/:id/reactivate
      def reactivate
        @represent = Represent.find(params[:id])
        status_updater = Represents::StatusUpdaterService.new(@represent)

        if status_updater.reactivate
          represent_success_response(
            'Representação reativada com sucesso',
            Represents::SerializerService.call(@represent)
          )
        else
          represent_error_response(
            'Erro ao reativar representação',
            @represent.errors.full_messages
          )
        end
      end

      # GET /api/v1/represents/by_representor/:representor_id
      def by_representor
        represents = query_service.by_representor(params[:representor_id])
        represent_success_response(
          'Clientes representados listados com sucesso',
          represents.map { |r| Represents::SerializerService.call(r) }
        )
      end

      private

      def set_represent
        @represent = Represent.by_team(current_team.id).find(params[:id])
      rescue ActiveRecord::RecordNotFound
        represent_not_found_response
      end

      def set_profile_customer
        return unless params[:profile_customer_id]

        @profile_customer = ProfileCustomer.joins(:customer)
                              .joins(customer: :teams)
                              .where(customers: { teams: { id: current_team.id } })
                              .find(params[:profile_customer_id])
      rescue ActiveRecord::RecordNotFound
        represent_not_found_response('Cliente não encontrado')
      end

      def represent_params
        params.expect(
          represent: [:profile_customer_id,
                      :representor_id,
                      :relationship_type,
                      :active,
                      :start_date,
                      :end_date,
                      :notes]
        )
      end

      def filter_params
        {
          active: params[:active],
          relationship_type: params[:relationship_type],
          current: params[:current]
        }
      end

      def build_represent
        represent = Represent.new(represent_params)
        represent.team = current_team
        represent.profile_customer = @profile_customer if @profile_customer
        represent
      end

      def query_service
        @query_service ||= Represents::QueryService.new(current_team)
      end

      def perform_authorization
        authorize [:admin, :work], :"#{action_name}?"
      end
    end
  end
end
