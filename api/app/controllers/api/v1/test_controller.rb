# frozen_string_literal: true

module Api
  module V1
    class TestController < ApplicationController
      def index
        render json: {
          success: true,
          message: 'API está funcionando corretamente!',
          data: {
            timestamp: Time.current.iso8601,
            environment: Rails.env,
            version: '1.0.0',
            status: 'healthy'
          }
        }, status: :ok
      end
    end
  end
end
