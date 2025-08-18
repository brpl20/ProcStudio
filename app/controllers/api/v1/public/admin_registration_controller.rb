# frozen_string_literal: true

module Api
  module V1
    module Public
      class AdminRegistrationController < ApplicationController
        def create
          ActiveRecord::Base.transaction do
            # Primeiro criar o team
            team = create_team_for_admin

            # Depois criar o admin associado ao team
            admin = Admin.new(admin_params.merge(team: team))

            # Usar save! para garantir rollback automático se falhar
            admin.save!

            # Se OAB foi fornecida, consultar API e criar ProfileAdmin
            create_profile_from_oab(admin) if admin.oab.present?

            render json: {
              success: true,
              message: 'Admin and team created successfully',
              data: build_response_data(admin)
            }, status: :created
          end
        rescue ActiveRecord::RecordInvalid => e
          Rails.logger.error "Validation error creating admin: #{e.message}"
          render json: {
            success: false,
            errors: e.record.errors.full_messages
          }, status: :unprocessable_entity
        rescue StandardError => e
          Rails.logger.error "Error creating admin and team: #{e.message}"
          render json: {
            success: false,
            errors: ['Erro interno do servidor. Tente novamente.']
          }, status: :internal_server_error
        end

        private

        def admin_params
          params.require(:admin).permit(:email, :password, :password_confirmation, :oab)
        end

        def create_team_for_admin
          # Buscar dados do advogado se OAB foi fornecida
          lawyer_name = nil
          if params.dig(:admin, :oab).present?
            lawyer_data = fetch_lawyer_data_from_oab(params[:admin][:oab])
            lawyer_name = build_full_name(lawyer_data) if lawyer_data
          end

          # Gerar subdomain baseado no nome do advogado ou email
          subdomain = TeamSubdomainGenerator.generate(
            name: lawyer_name,
            email: params.dig(:admin, :email)
          )

          # Gerar nome do team
          team_name = generate_team_name(lawyer_name, params.dig(:admin, :email))

          Team.create!(
            name: team_name,
            subdomain: subdomain,
            settings: { auto_created: true }
          )
        end

        def fetch_lawyer_data_from_oab(oab_number)
          oab_service = OabApiService.new
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

        def create_profile_from_oab(admin)
          oab_service = OabApiService.new
          lawyer_data = oab_service.find_lawyer(admin.oab)

          return unless lawyer_data

          ActiveRecord::Base.transaction do
            profile_admin = admin.create_profile_admin!(
              name: lawyer_data[:name],
              last_name: lawyer_data[:last_name],
              oab: lawyer_data[:oab],
              role: 'lawyer',
              status: 'active'
              # Campos opcionais deixados em branco para serem preenchidos via modal
              # civil_status, cpf, gender, nationality, rg, birth serão nil
            )

            # Criar endereço se dados estiverem disponíveis
            create_address_from_data(profile_admin, lawyer_data) if has_address_data?(lawyer_data)

            # Criar telefone se disponível
            create_phone_from_data(profile_admin, lawyer_data) if lawyer_data[:phone].present?

            # Salvar URL da foto do perfil como atributo temporário
            profile_admin.update_column(:origin, lawyer_data[:profile_picture_url]) if lawyer_data[:profile_picture_url]
          end
        rescue StandardError => e
          Rails.logger.error "Error creating profile from OAB: #{e.message}"
          # Não falha o cadastro se não conseguir criar o profile
        end

        def has_address_data?(lawyer_data)
          lawyer_data[:address].present? || lawyer_data[:city].present?
        end

        def create_address_from_data(profile_admin, lawyer_data)
          address = Address.create!(
            description: 'Endereço Principal',
            zip_code: lawyer_data[:zip_code],
            street: extract_street(lawyer_data[:address]),
            number: extract_number(lawyer_data[:address]),
            neighborhood: extract_neighborhood(lawyer_data[:address]),
            city: lawyer_data[:city],
            state: lawyer_data[:state]
          )

          AdminAddress.create!(
            profile_admin: profile_admin,
            address: address
          )
        end

        def create_phone_from_data(profile_admin, lawyer_data)
          phone = Phone.create!(
            phone_type: 'mobile',
            number: lawyer_data[:phone]
          )

          AdminPhone.create!(
            profile_admin: profile_admin,
            phone: phone
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

        def build_response_data(admin)
          # Response simples para registro - lógica de completeness vai para o login
          data = {
            id: admin.id,
            email: admin.email,
            oab: admin.oab,
            team: {
              id: admin.team.id,
              name: admin.team.name,
              subdomain: admin.team.subdomain
            }
          }

          # Informar se ProfileAdmin foi criado com dados da OAB
          if admin.profile_admin.present?
            data[:profile_created] = true
            data[:profile] = {
              name: admin.profile_admin.name,
              last_name: admin.profile_admin.last_name,
              role: admin.profile_admin.role
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
