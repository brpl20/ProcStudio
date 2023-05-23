# frozen_string_literal: true

module Api
  module V1
    class PowersController < BackofficeController
      before_action :retrieve_power, only: %i[update show]

      def index
        powers = Power.all
        render json: PowerSerializer.new(
          powers,
          meta: {
            total_count: powers.offset(nil).limit(nil).count
          }
        ), status: :ok
      end

      def create
        power = Power.new(powers_params)
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

      def show
        render json: PowerSerializer.new(
          @power
        ), status: :ok
      end

      private

      def powers_params
        params.require(:power).permit(:description, :category)
      end

      def retrieve_power
        @power = Power.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        head :not_found
      end
    end
  end
end
