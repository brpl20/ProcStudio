# frozen_string_literal: true

class OfficesController < ApplicationController
  before_action :retrieve_office, only: %i[show edit update destroy]

  def index
    @offices = OfficeFilter.retrieve_offices
  end

  def show; end

  def new
    @office = Office.new
    @office.bank_accounts.build
    @office.phones.build
    @office.emails.build
  end

  def edit; end

  def create
    @office = Office.new(office_params)

    if @office.save
      redirect_to offices_path, notice: 'Escritório criado com sucesso!'
    else
      render :new
    end
  end

  def update
    if @office.update(office_params)
      redirect_to offices_path, notice: 'Escritório atualizado com sucesso!'
    else
      render :edit
    end
  end

  def destroy
    if @office.destroy
      redirect_to offices_url, notice: 'Escritório apagado com sucesso!'
    else
      render :index, notice: 'Desculpe, houve um problema, tente novamente daqui a alguns minutos'
    end
  end

  private

  def retrieve_office
    @office = OfficeFilter.retrieve_office(params[:id])
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
      phones_attributes: %i[id phone _destroy],
      emails_attributes: %i[id email _destroy],
      bank_accounts_attributes: %i[id bank_name type_account agency account operation _destroy]
    )
  end
end
