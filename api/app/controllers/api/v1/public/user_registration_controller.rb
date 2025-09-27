# frozen_string_literal: true

module Api
  module V1
    module Public
      class UserRegistrationController < ApplicationController
        include ErrorHandler

        def create
          ActiveRecord::Base.transaction do
            # Primeiro criar o team
            team = create_team_for_user

            # Depois criar o user associado ao team
            user = User.new(user_params.merge(team: team))

            # Usar save! para garantir rollback automático se falhar
            user.save!

            # Se OAB foi fornecida, consultar API e criar UserProfile
            create_profile_from_oab(user) if user.oab.present?

            # Recarregar user para pegar o user_profile que foi criado
            user.reload

            render json: {
              success: true,
              message: 'User and team created successfully',
              data: build_response_data(user)
            }, status: :created
          end
        rescue ActiveRecord::RecordInvalid => e
          Rails.logger.error "Validation error creating user: #{e.message}"
          error_messages = e.record.errors.full_messages
          render json: {
            success: false,
            message: error_messages.first, # Single user-friendly message
            errors: error_messages # Array for detailed errors
          }, status: :unprocessable_entity
        rescue StandardError => e
          Rails.logger.error "Error creating user and team: #{e.message}"
          error_message = 'Erro interno do servidor. Tente novamente.'
          render json: {
            success: false,
            message: error_message,
            errors: [error_message]
          }, status: :internal_server_error
        end

        private

        def user_params
          params.expect(user: [:email, :password, :password_confirmation, :oab])
        end

        def create_team_for_user
          # Buscar dados do advogado se OAB foi fornecida
          lawyer_name = nil
          if params.dig(:user, :oab).present?
            lawyer_data = fetch_lawyer_data_from_oab(params[:user][:oab])
            lawyer_name = build_full_name(lawyer_data) if lawyer_data
          end

          # Gerar subdomain baseado no nome do advogado ou email
          subdomain = TeamSubdomainGenerator.generate(
            name: lawyer_name,
            email: params.dig(:user, :email)
          )

          # Gerar nome do team
          team_name = generate_team_name(lawyer_name, params.dig(:user, :email))

          Team.create!(
            name: team_name,
            subdomain: subdomain,
            settings: { auto_created: true }
          )
        end

        def fetch_lawyer_data_from_oab(oab_number)
          oab_service = LegalData::LegalDataService.new
          oab_service.find_lawyer(oab_number)
        rescue StandardError => e
          Rails.logger.warn "Could not fetch OAB data for team creation: #{e.message}"
          nil
        end

        def build_full_name(lawyer_data)
          return nil unless lawyer_data

          "#{lawyer_data[:name]} #{lawyer_data[:last_name]}".strip.presence
        end

        def generate_team_name(lawyer_name, email)
          if lawyer_name.present?
            "Escritório #{lawyer_name}"
          elsif email.present?
            email_prefix = email.split('@').first.titleize
            "Escritório #{email_prefix}"
          else
            'Meu Escritório'
          end
        end

        def create_profile_from_oab(user)
          oab_service = LegalData::LegalDataService.new
          lawyer_data = oab_service.find_lawyer(user.oab)

          Rails.logger.info "OAB API returned data: #{lawyer_data.inspect}" if Rails.env.development?

          return unless lawyer_data

          ActiveRecord::Base.transaction do
            user_profile = user.create_user_profile!(
              name: lawyer_data[:name],
              last_name: lawyer_data[:last_name],
              oab: lawyer_data[:oab],
              role: 'lawyer',
              status: 'active',
              gender: lawyer_data[:gender]
              # Campos opcionais deixados em branco para serem preenchidos via modal
              # civil_status, cpf, nationality, rg, birth serão nil
            )

            Rails.logger.info "Created UserProfile: #{user_profile.inspect}" if Rails.env.development?

            # Criar endereço se dados estiverem disponíveis
            create_address_from_data(user_profile, lawyer_data) if has_address_data?(lawyer_data)

            # Criar telefone se disponível
            create_phone_from_data(user_profile, lawyer_data) if lawyer_data[:phone].present?

            # Attach avatar from S3 URL if available
            if lawyer_data[:profile_picture_url].present?
              avatar_service = LegalData::AvatarAttachmentService.new
              success = avatar_service.attach_from_url(user_profile, lawyer_data[:profile_picture_url])

              # Store the original URL as backup in origin field
              user_profile.update(origin: lawyer_data[:profile_picture_url])

              Rails.logger.info "Avatar attachment #{success ? 'succeeded' : 'failed'} for user_profile #{user_profile.id}"
            end
          end
        rescue StandardError => e
          Rails.logger.error "Error creating profile from OAB: #{e.message}"
          # Não falha o cadastro se não conseguir criar o profile
        end

        def has_address_data?(lawyer_data)
          lawyer_data[:address].present? || lawyer_data[:city].present?
        end

        def create_address_from_data(user_profile, lawyer_data)
          # Create address directly through polymorphic association
          user_profile.addresses.create!(
            zip_code: lawyer_data[:zip_code],
            street: extract_street(lawyer_data[:address]),
            number: extract_number(lawyer_data[:address]),
            neighborhood: extract_neighborhood(lawyer_data[:address]),
            city: lawyer_data[:city],
            state: lawyer_data[:state],
            address_type: 'main'
          )
        end

        def create_phone_from_data(user_profile, lawyer_data)
          # Create phone directly through polymorphic association
          user_profile.phones.create!(
            phone_number: lawyer_data[:phone]
          )
        end

        def extract_street(address_str)
          return nil if address_str.blank?

          # Exemplo: "RUA CARIMAS, Nº 288, SANTA CRUZ" -> "RUA CARIMAS"
          parts = address_str.split(',')
          parts.first&.strip
        end

        def extract_number(address_str)
          return nil if address_str.blank?

          # Procura por "Nº 288" ou similar
          match = address_str.match(/[Nn]º?\s*(\d+)/)
          match ? match[1].to_i : nil
        end

        def extract_neighborhood(address_str)
          return nil if address_str.blank?

          # Exemplo: "RUA CARIMAS, Nº 288, SANTA CRUZ" -> "SANTA CRUZ"
          parts = address_str.split(',')
          return nil if parts.length < 3

          parts.last&.strip
        end

        def build_response_data(user)
          # Response simples para registro - lógica de completeness vai para o login
          data = {
            id: user.id,
            email: user.email,
            oab: user.oab,
            team: {
              id: user.team.id,
              name: user.team.name,
              subdomain: user.team.subdomain
            }
          }

          # Informar se UserProfile foi criado com dados da OAB
          if user.user_profile.present?
            data[:profile_created] = true
            data[:profile] = {
              name: user.user_profile.name,
              last_name: user.user_profile.last_name,
              role: user.user_profile.role
            }
          else
            data[:profile_created] = false
          end

          data
        end
      end
    end
  end
end
