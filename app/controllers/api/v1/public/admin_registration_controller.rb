# frozen_string_literal: true

module Api
  module V1
    module Public
      class AdminRegistrationController < ApplicationController
        def create
          admin = Admin.new(admin_params)
          
          if admin.save
            # Se OAB foi fornecida, consultar API e criar ProfileAdmin
            if admin.oab.present?
              create_profile_from_oab(admin)
            end
            
            render json: {
              success: true,
              message: 'Admin created successfully',
              data: build_response_data(admin)
            }, status: :created
          else
            render json: {
              success: false,
              errors: admin.errors.full_messages
            }, status: :unprocessable_entity
          end
        end

        private

        def admin_params
          params.require(:admin).permit(:email, :password, :password_confirmation, :oab)
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
          data = {
            id: admin.id,
            email: admin.email,
            oab: admin.oab
          }
          
          if admin.profile_admin.present?
            data[:profile_created] = true
            data[:profile] = {
              name: admin.profile_admin.name,
              last_name: admin.profile_admin.last_name,
              role: admin.profile_admin.role
            }
          end
          
          data
        end
      end
    end
  end
end