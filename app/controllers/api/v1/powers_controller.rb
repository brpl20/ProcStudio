# frozen_string_literal: true

module Api
  module V1
    class PowersController < BackofficeController
      include TeamScoped

      before_action :retrieve_power, only: [:update, :show, :destroy]
      before_action :perform_authorization

      after_action :verify_authorized

      def index
        # System powers (available to all) + custom powers from current team
        powers = Power.system_powers.or(Power.where(created_by_team: @current_user.team))

        render json: PowerSerializer.new(
          powers.includes(:law_area).order(:category, :law_area_id, :description),
          meta: {
            total_count: powers.count
          }
        ), status: :ok
      end

      def show
        render json: PowerSerializer.new(
          @power
        ), status: :ok
      end

      def create
        power = Power.new(powers_params)

        # Se não é um poder base e tem law_area_id, pode ser customizado
        if !power.is_base? && power.law_area_id.present? && power.law_area&.system_area?
          # Se é uma área do sistema, o poder pode ser customizado
          power.created_by_team = @current_user.team
        end

        if power.save
          render json: PowerSerializer.new(
            power
          ), status: :created
        else
          render(
            status: :bad_request,
            json: { errors: [{ code: power.errors.full_messages }] }
          )
        end
      rescue StandardError => e
        render(
          status: :bad_request,
          json: { errors: [{ code: e }] }
        )
      end

      def update
        if @power.update(powers_params)
          render json: PowerSerializer.new(
            @power
          ), status: :ok
        else
          render(
            status: :bad_request,
            json: { errors: [{ code: @power.errors.full_messages }] }
          )
        end
      end

      def destroy
        @power.destroy
      end

      private

      def powers_params
        params.expect(power: [:description, :category, :law_area_id, :is_base])
      end

      def retrieve_power
        # Só permite acesso a poderes do sistema ou do próprio team
        @power = Power.system_powers
                   .or(Power.where(created_by_team: @current_user.team))
                   .find(params[:id])
      rescue ActiveRecord::RecordNotFound
        head :not_found
      end

      def perform_authorization
        authorize [:admin, :power], :"#{action_name}?"
      end
    end
  end
end
