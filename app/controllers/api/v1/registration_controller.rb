# frozen_string_literal: true

module Api
  module V1
    class RegistrationController < ApplicationController
      def create
        ActiveRecord::Base.transaction do
          # Criar Admin
          admin = Admin.new(
            email: registration_params[:email],
            password: registration_params[:password],
            password_confirmation: registration_params[:password_confirmation]
          )

          unless admin.save
            return render json: { errors: admin.errors.full_messages }, status: :unprocessable_entity
          end

          # Criar Team inicial com base no email
          team = Team.new(
            name: "Team #{admin.email.split('@').first.capitalize}",
            subdomain: registration_params[:email].split('@').first.downcase.gsub(/[^a-z0-9]/, ''),
            owner_admin: admin,
            main_admin: admin
          )

          unless team.save
            return render json: { errors: team.errors.full_messages }, status: :unprocessable_entity
          end

          # Criar TeamMembership
          membership = TeamMembership.create!(
            team: team,
            admin: admin,
            role: 'owner',
            status: 'active'
          )


          render json: {
            message: 'Registration successful',
            admin: {
              id: admin.id,
              email: admin.email,
              needs_profile_setup: true
            },
            team: {
              id: team.id,
              name: team.name
            }
          }, status: :created
        end
      rescue StandardError => e
        render json: { errors: [e.message] }, status: :unprocessable_entity
      end

      private

      def registration_params
        params.require(:registration).permit(
          :email,
          :password,
          :password_confirmation
        )
      end
    end
  end
end