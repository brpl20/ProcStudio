# frozen_string_literal: true

module Api
  module V1
    class ExternalAuthenticationsController < ApplicationController
      require 'net/http'
      require 'json'

      def authenticate
        authenticate_with_google
      end

      private

      def authenticate_with_google
        access_token = params[:accessToken]

        uri = URI("https://www.googleapis.com/oauth2/v3/tokeninfo?access_token=#{access_token}")
        response = Net::HTTP.get(uri)

        if response.present? && JSON.parse(response)['email']
          p '*************************************************************'
          email = params[:user][:email]
          # name = params[:user][:name]
          # image = params[:user][:image]

          user = Admin.find_by(email: email)

          sign_in(user) # Autenticar o usuário manualmente usando Devise
          render json: { message: 'Logged in successfully' }
        else
          render json: { error: 'Invalid access token' }, status: :unauthorized
        end
      end
    end
  end
end
