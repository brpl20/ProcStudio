# frozen_string_literal: true

module Api
  module V1
    class RepresentsController < BackofficeController
      before_action :set_represent, only: [:show, :update, :destroy]
      before_action :set_profile_customer, only: [:index, :create]
      before_action :perform_authorization
      after_action :verify_authorized

      # GET /api/v1/profile_customers/:profile_customer_id/represents
      # GET /api/v1/represents (for all represents in the team)
      def index
        represents = if @profile_customer
                       # Get represents for a specific customer
                       @profile_customer.represents
                         .includes(:representor, :profile_customer)
                         .by_team(current_team.id)
                     else
                       # Get all represents for the current team
                       Represent.includes(:representor, :profile_customer)
                         .by_team(current_team.id)
                     end

        # Apply filters
        represents = apply_filters(represents)

        render json: {
          success: true,
          message: 'Representações listadas com sucesso',
          data: represents.map { |r| serialize_represent(r) },
          meta: {
            total_count: represents.count
          }
        }, status: :ok
      end

      # GET /api/v1/represents/:id
      def show
        render json: {
          success: true,
          message: 'Representação encontrada com sucesso',
          data: serialize_represent(@represent, detailed: true)
        }, status: :ok
      end

      # POST /api/v1/profile_customers/:profile_customer_id/represents
      # POST /api/v1/represents
      def create
        represent = Represent.new(represent_params)
        represent.team = current_team
        represent.profile_customer = @profile_customer if @profile_customer

        if represent.save
          render json: {
            success: true,
            message: 'Representação criada com sucesso',
            data: serialize_represent(represent, detailed: true)
          }, status: :created
        else
          render json: {
            success: false,
            message: 'Erro ao criar representação',
            errors: represent.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/represents/:id
      def update
        if @represent.update(represent_params)
          render json: {
            success: true,
            message: 'Representação atualizada com sucesso',
            data: serialize_represent(@represent, detailed: true)
          }, status: :ok
        else
          render json: {
            success: false,
            message: 'Erro ao atualizar representação',
            errors: @represent.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/represents/:id
      def destroy
        if @represent.destroy
          render json: {
            success: true,
            message: 'Representação removida com sucesso'
          }, status: :ok
        else
          render json: {
            success: false,
            message: 'Erro ao remover representação',
            errors: @represent.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      # POST /api/v1/represents/:id/deactivate
      def deactivate
        @represent = Represent.find(params[:id])

        if @represent.update(active: false, end_date: Date.current)
          render json: {
            success: true,
            message: 'Representação desativada com sucesso',
            data: serialize_represent(@represent)
          }, status: :ok
        else
          render json: {
            success: false,
            message: 'Erro ao desativar representação',
            errors: @represent.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      # POST /api/v1/represents/:id/reactivate
      def reactivate
        @represent = Represent.find(params[:id])

        if @represent.update(active: true, end_date: nil)
          render json: {
            success: true,
            message: 'Representação reativada com sucesso',
            data: serialize_represent(@represent)
          }, status: :ok
        else
          render json: {
            success: false,
            message: 'Erro ao reativar representação',
            errors: @represent.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      # GET /api/v1/represents/by_representor/:representor_id
      def by_representor
        representor_id = params[:representor_id]
        represents = Represent.includes(:profile_customer)
                       .by_representor(representor_id)
                       .by_team(current_team.id)
                       .active

        render json: {
          success: true,
          message: 'Clientes representados listados com sucesso',
          data: represents.map { |r| serialize_represent(r) }
        }, status: :ok
      end

      private

      def set_represent
        @represent = Represent.by_team(current_team.id).find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: {
          success: false,
          message: 'Representação não encontrada'
        }, status: :not_found
      end

      def set_profile_customer
        return unless params[:profile_customer_id]

        @profile_customer = ProfileCustomer.joins(:customer)
                              .joins(customer: :teams)
                              .where(customers: { teams: { id: current_team.id } })
                              .find(params[:profile_customer_id])
      rescue ActiveRecord::RecordNotFound
        render json: {
          success: false,
          message: 'Cliente não encontrado'
        }, status: :not_found
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

      def apply_filters(represents)
        # Filter by active status
        if params[:active].present?
          represents = params[:active] == 'true' ? represents.active : represents.inactive
        end

        # Filter by relationship type
        if params[:relationship_type].present?
          represents = represents.where(relationship_type: params[:relationship_type])
        end

        # Filter by date range
        represents = represents.current if params[:current].present? && params[:current] == 'true'

        represents
      end

      def serialize_represent(represent, detailed: false)
        data = {
          id: represent.id,
          profile_customer_id: represent.profile_customer_id,
          profile_customer_name: represent.profile_customer&.full_name,
          profile_customer_cpf: represent.profile_customer&.cpf,
          profile_customer_capacity: represent.profile_customer&.capacity,
          representor_id: represent.representor_id,
          representor_name: represent.representor&.full_name,
          representor_cpf: represent.representor&.cpf,
          relationship_type: represent.relationship_type,
          active: represent.active,
          start_date: represent.start_date,
          end_date: represent.end_date,
          created_at: represent.created_at,
          updated_at: represent.updated_at
        }

        if detailed
          data.merge!(
            notes: represent.notes,
            team_id: represent.team_id,
            profile_customer: {
              id: represent.profile_customer&.id,
              name: represent.profile_customer&.full_name,
              cpf: represent.profile_customer&.cpf,
              capacity: represent.profile_customer&.capacity,
              birth: represent.profile_customer&.birth,
              email: represent.profile_customer&.customer&.email
            },
            representor: {
              id: represent.representor&.id,
              name: represent.representor&.full_name,
              cpf: represent.representor&.cpf,
              profession: represent.representor&.profession,
              email: represent.representor&.customer&.email,
              phone: represent.representor&.last_phone
            }
          )
        end

        data
      end

      def perform_authorization
        authorize [:admin, :work], :"#{action_name}?"
      end
    end
  end
end
