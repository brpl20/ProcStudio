# frozen_string_literal: true

module Api
  module V1
    class UsersController < BackofficeController
      include UserResponses

      before_action :retrieve_user, only: [:update, :show]
      before_action :perform_authorization, unless: -> { Rails.env.development? && params[:all_teams] == 'true' }

      after_action :verify_authorized, unless: -> { Rails.env.development? && params[:all_teams] == 'true' }

      def index
        users = Users::QueryService.build_query(
          params: params,
          team_scoped_proc: method(:team_scoped)
        )

        serialized_data = Users::SerializerService.serialize_users_with_meta(users)
        render_users_success(data: serialized_data[:data], meta: serialized_data[:meta])
      rescue StandardError => e
        render_internal_error(e)
      end

      def show
        serialized_data = Users::SerializerService.serialize_user(@user)
        render_user_success(data: serialized_data[:data], message: 'Usuário obtido com sucesso')
      rescue StandardError => e
        render_internal_error(e)
      end

      def create
        result = Users::CreationService.create_user(
          params: users_params,
          current_team: current_team,
          current_user: @current_user
        )

        if result.success?
          serialized_data = Users::SerializerService.serialize_user(result.data)
          render_user_success(
            data: serialized_data[:data],
            message: 'Usuário criado com sucesso',
            status: :created
          )
        else
          render_user_error(errors: result.errors, status: :bad_request)
        end
      rescue StandardError => e
        render_user_error(errors: [e.message], status: :bad_request)
      end

      def update
        result = Users::UpdateService.update_user(user: @user, params: users_params)

        if result.success?
          serialized_data = Users::SerializerService.serialize_user(result.data)
          render_user_success(
            data: serialized_data[:data],
            message: 'Usuário atualizado com sucesso'
          )
        else
          render_user_error(errors: result.errors)
        end
      rescue StandardError => e
        render_internal_error(e)
      end

      def destroy
        result = Users::DeletionService.delete_user(
          user_id: params[:id],
          destroy_fully: destroy_fully?
        )

        if result.success?
          render_user_success(
            data: { id: result.data[:id] },
            message: result.data[:message]
          )
        else
          handle_deletion_error(result.errors)
        end
      rescue StandardError => e
        render_user_error(errors: [e.message])
      end

      def restore
        result = Users::RestorationService.restore_user(user_id: params[:id])

        if result.success?
          serialized_data = Users::SerializerService.serialize_user(result.data)
          render_user_success(
            data: serialized_data[:data],
            message: 'Usuário restaurado com sucesso'
          )
        else
          handle_restoration_error(result.errors)
        end
      rescue StandardError => e
        render_internal_error(e)
      end

      private

      def users_params
        params.expect(
          user: [
            :email, :access_email, :password, :password_confirmation, :status, # <= Status do User
            { user_profile_attributes: user_profile_permitted_attributes } # <= Atributos do UserProfile
          ]
        )
      end

      def retrieve_user
        @user = team_scoped(User).find(params[:id])
      end

      def perform_authorization
        authorize [:admin, :user], :"#{action_name}?"
      end

      
      def user_profile_permitted_attributes
        [
          :id, # Importante para atualizar um UserProfile existente
          :role, # :status FOI REMOVIDO DAQUI
          :office_id, :name, :last_name,
          :gender, :oab, :rg, :cpf, :nationality, :civil_status,
          :birth, :mother_name,
          # Permitir atributos aninhados para User, incluindo o 'status' e o 'id' do User
          # Aqui permitimos todos os campos que podem vir de 'user_attributes' dentro de 'user_profile_attributes'
          { user_attributes: %i[id status email password password_confirmation] },
          # Permitir outros nested attributes de UserProfile
          { phones_attributes: %i[id phone_number _destroy] },
          { addresses_attributes: %i[id street number complement neighborhood city state zip_code _destroy] }
        ]
      end

      def destroy_fully?
        params[:destroy_fully] == 'true'
      end

      def handle_deletion_error(errors)
        if errors.include?('Usuário não encontrado')
          render_not_found_error
        else
          render_user_error(errors: errors)
        end
      end

      def handle_restoration_error(errors)
        if errors.include?('Usuário não encontrado')
          render_not_found_error
        else
          render_user_error(errors: errors)
        end
      end
    end
  end
end