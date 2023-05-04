# frozen_string_literal: true

class OfficesController < BackofficeController
  respond_to :json
  before_action :retrieve_office, only: %i[show update destroy]
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found_response

  def index
    @offices = OfficeFilter.retrieve_offices
    respond_with @offices
  end

  def show; end

  def create
    @office = build_office

    if @office.save
      render json: { message: 'Escritório criado com sucesso' }, status: :created
    else
      render json: { errors: office.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @office.update(office_params)
      render json: { message: 'Escritório atualizado com sucesso' }, status: 200
    else
      render json: { errors: office.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if @office.destroy
      render json: { message: 'Escritório apagado com sucesso' }, status: 200
    else
      render json: { errors: office.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def build_office
    Office.new(office_params)
  end

  def retrieve_office
    @office = OfficeFilter.retrieve_office(params[:id])
  end

  def render_not_found_response
    render json: { errors: 'Escritório não encontrado' }, status: :not_found
  end

  def office_params
    params.require(:office).permit(
      :name, :cnpj,
      :oab, :society,
      :foundation, :site,
      :cep, :street,
      :number, :neighborhood,
      :city, :state,
      :profile_admin_id,
      :office_type_id,
      phones_attributes: %i[id phone],
      emails_attributes: %i[id email],
      bank_accounts_attributes: %i[id bank_name type_account agency account operation]
    )
  end
end
